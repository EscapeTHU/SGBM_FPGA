/* -*-c++-*- SemiGlobalMatching - Copyright (C) 2022.
 * Author	: EscapeTHU
 */
#include <SemiGlobalMatching.h>
#include <opencv2/opencv.hpp>
#include <fstream>
#include <stdio.h>
#include <unistd.h>
#include <vector>

std::vector<std::string> splitString(const std::string &str, const std::string &delimiter)
{
    std::vector<std::string> result;
    size_t start = 0, end = 0;
    while ((end = str.find(delimiter, start)) != std::string::npos)
    {
        result.push_back(str.substr(start, end - start));
        start = end + delimiter.length();
    }
    result.push_back(str.substr(start));
    return result;
}

int main(int argv, char **argc)
{

    char cwd[256];
    if (getcwd(cwd, sizeof(cwd)) == nullptr)
    {
        std::cerr << "Failed to get current working directory" << std::endl;
        return 1;
    }
    std::string cwd_ = std::string(cwd);
    cwd_ = (cv::String)splitString(cwd_, "awesome-sgbm").at(0);

    if (argv < 3)
    {
        std::cout << "please input the left and right image path..." << std::endl;
        return -1;
    }

    // read image
    std::string path_left = argc[1];
    std::string path_right = argc[2];

    cv::Mat img_left_c = cv::imread(path_left, cv::IMREAD_COLOR);
    cv::Mat img_left = cv::imread(path_left, cv::IMREAD_GRAYSCALE);
    cv::Mat img_right = cv::imread(path_right, cv::IMREAD_GRAYSCALE);

    // save image
    cv::String pl = "awesome-sgbm/Data/FPGA_proc/pic/grey_left.png";
    cv::String pr = "awesome-sgbm/Data/FPGA_proc/pic/grey_right.png";
    pl = cwd_ + pl;
    pr = cwd_ + pr;
    
    cv::imwrite(pl, img_left);
    cv::imwrite(pr, img_right);

    cv::namedWindow("img_left_c", 1);
    cv::imshow("img_left_c", img_left_c);

    cv::waitKey(30);

    cv::namedWindow("img_left", 1);
    cv::imshow("img_left", img_left);

    cv::waitKey(30);

    cv::namedWindow("img_right", 1);
    cv::imshow("img_right", img_right);

    cv::waitKey(30);

    if (img_left.data == nullptr || img_right.data == nullptr)
    {
        std::cout << "fail to read images" << std::endl;
        return -1;
    }
    if (img_left.rows != img_right.rows || img_left.cols != img_right.cols)
    {
        std::cout << "img_left.size not equals img_right" << std::endl;
        return -1;
    }

    const sint32 width = static_cast<uint32>(img_left.cols);
    const sint32 height = static_cast<uint32>(img_right.rows);
    std::cout << "width of input picture == " << width << std::endl;
    std::cout << "height of input picture == " << height << std::endl;

    // the graydata of the left and right image
    auto bytes_left = new uint8[width * height];
    auto bytes_right = new uint8[width * height];
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            bytes_left[i * width + j] = img_left.at<uint8>(i, j);
            bytes_right[i * width + j] = img_right.at<uint8>(i, j);
        }
    }
    // SGM匹配参数设计
    SemiGlobalMatching::SGMOption sgm_option;
    // 聚合路径数
    sgm_option.num_paths = 4;
    // 候选视差范围
    sgm_option.min_disparity = argv < 4 ? 0 : atoi(argc[3]);
    sgm_option.max_disparity = argv < 5 ? 64 : atoi(argc[4]);
    std::cout << "argc[3]== " << argc[3] << std::endl;
    std::cout << "argc[4]== " << argc[4] << std::endl;
    std::cout << "sgm_option.min_disparity == " << sgm_option.min_disparity << std::endl;
    std::cout << "sgm_option.max_disparity == " << sgm_option.max_disparity << std::endl;
    // census窗口类型
    sgm_option.census_size = SemiGlobalMatching::Census5x5;
    // 一致性检查
    sgm_option.is_check_lr = true;
    sgm_option.lrcheck_thres = 1.0f;
    // 唯一性约束
    sgm_option.is_check_unique = true;
    sgm_option.uniqueness_ratio = 0.99;
    // 剔除小连通区
    sgm_option.is_remove_speckles = true;
    sgm_option.min_speckle_aera = 50;
    // 惩罚项P1、P2
    sgm_option.p1 = 10;
    sgm_option.p2_init = 150;
    // 视差图填充
    sgm_option.is_fill_holes = true;

    // 定义SGM匹配类实例
    SemiGlobalMatching sgm;

    // 初始化
    if (!sgm.Initialize(width, height, sgm_option))
    {
        std::cout << "SGM初始化失败！" << std::endl;
        return -2;
    }

    // 匹配
    auto disparity = new float32[uint32(width * height)]();
    auto disparity_temp = new float32[uint32(width * height)]();
    if (!sgm.Match(bytes_left, bytes_right, disparity, disparity_temp))
    {
        std::cout << "SGM匹配失败！" << std::endl;
        return -2;
    }

    // Fetch census_left and census_right
    // the pointer for census left and census right in order to get census data
    auto census_left = new uint32[uint32(width * height)]();
    auto census_right = new uint32[uint32(width * height)]();
    if (!sgm.GetCensus(census_left, census_right))
    {
        std::cout << "GetCensus Failed!" << std::endl;
        return -2;
    }

    // Fetch cost_init
    sint32 disp_range = (sgm_option.max_disparity - sgm_option.min_disparity);
    auto cost_init = new uint8[uint32(width * height * disp_range)]();
    if (!sgm.GetOriginCost(cost_init))
    {
        std::cout << "GetOriginCost Failed!" << std::endl;
        return -2;
    }

    // Fetch cost_aggr
    auto cost_aggr_lr = new uint8[uint32(width * height * disp_range)]();
    auto cost_aggr_rl = new uint8[uint32(width * height * disp_range)]();
    if (!sgm.GetAggrCost(cost_aggr_lr, 1))
    {
        std::cout << "GetOriginCost Failed!" << std::endl;
        return -2;
    }
    if (!sgm.GetAggrCost(cost_aggr_rl, 2))
    {
        std::cout << "GetOriginCost Failed!" << std::endl;
        return -2;
    }

    // Fetch my disparity
    auto my_disparity = new uint32[uint32(width * height)]();
    if (!sgm.GetDisparity(my_disparity))
    {
        std::cout << "GetMyDisparity Failed!" << std::endl;
    }

    // 显示视差图
    cv::Mat disp_mat = cv::Mat(height, width, CV_8UC1);
    float min_disp = width, max_disp = -width;
    for (sint32 i = 0; i < height; i++)
    {
        for (sint32 j = 0; j < width; j++)
        {
            const float32 disp = disparity[i * width + j];
            if (disp != Invalid_Float)
            {
                min_disp = std::min(min_disp, disp);
                max_disp = std::max(max_disp, disp);
            }
        }
    }
    for (sint32 i = 0; i < height; i++)
    {
        for (sint32 j = 0; j < width; j++)
        {
            const float32 disp = disparity[i * width + j];
            if (disp == Invalid_Float)
            {
                disp_mat.data[i * width + j] = 0;
            }
            else
            {
                disp_mat.data[i * width + j] = static_cast<uchar>((disp - min_disp) / (max_disp - min_disp) * 255);
            }
        }
    }

    cv::Mat disp_temp_mat = cv::Mat(height, width, CV_8UC1);
    float min_disp_temp = width, max_disp_temp = -width;
    for (sint32 i = 0; i < height; i++)
    {
        for (sint32 j = 0; j < width; j++)
        {
            const float32 disp_temp = disparity_temp[i * width + j];
            if (disp_temp != Invalid_Float)
            {
                min_disp_temp = std::min(min_disp_temp, disp_temp);
                max_disp_temp = std::max(max_disp_temp, disp_temp);
            }
        }
    }
    for (sint32 i = 0; i < height; i++)
    {
        for (sint32 j = 0; j < width; j++)
        {
            const float32 disp_temp = disparity_temp[i * width + j];
            if (disp_temp == Invalid_Float)
            {
                disp_temp_mat.data[i * width + j] = 0;
            }
            else
            {
                disp_temp_mat.data[i * width + j] = static_cast<uchar>((disp_temp - min_disp_temp) / (max_disp_temp - min_disp_temp) * 255);
            }
        }
    }

    // 保存结果txt
    std::string disparity_txt = cwd_ + "awesome-sgbm/Data/FPGA_proc/disparity/disparity.txt";
    std::string disparity_temp_txt = cwd_ + "awesome-sgbm/Data/FPGA_proc/disparity/disparity_temp.txt";
    std::FILE *FilePosition;
    std::FILE *FilePosition_temp;
    FilePosition = std::fopen(disparity_txt.c_str(), "w");
    FilePosition_temp = std::fopen(disparity_temp_txt.c_str(), "w");
    std::cout << "Start Writing Disparity..." << std::endl;
    for (sint32 i = 0; i < height; i++)
    {
        for (sint32 j = 0; j < width; j++)
        {
            // std::cout<<"Hello!"<<std::endl;
            if (j == width - 1)
            {
                std::fprintf(FilePosition, "%f\n", disparity[i * width + j]);
                std::fprintf(FilePosition_temp, "%f\n", disparity_temp[i * width + j]);
            }
            else
            {
                std::fprintf(FilePosition, "%f\t", disparity[i * width + j]);
                std::fprintf(FilePosition_temp, "%f\t", disparity_temp[i * width + j]);
            }
        }
    }
    std::fclose(FilePosition);
    std::fclose(FilePosition_temp);
    std::cout << "Writing Disparity Finished!" << std::endl;

    // Save Census left and Census right
    std::FILE *FilePosition_left_d;
    std::FILE *FilePosition_right_d;
    std::FILE *FilePosition_left_X;
    std::FILE *FilePosition_right_X;
    std::string c_l_d_txt = cwd_ + "awesome-sgbm/Data/FPGA_proc/cencus/census_left_d.txt";
    std::string c_r_d_txt = cwd_ + "awesome-sgbm/Data/FPGA_proc/cencus/census_right_d.txt";
    std::string c_l_X_txt = cwd_ + "awesome-sgbm/Data/FPGA_proc/cencus/census_left_X.txt";
    std::string c_r_X_txt = cwd_ + "awesome-sgbm/Data/FPGA_proc/cencus/census_right_X.txt";
    FilePosition_left_d = std::fopen(c_l_d_txt.c_str(), "w");
    FilePosition_right_d = std::fopen(c_r_d_txt.c_str(), "w");
    FilePosition_left_X = std::fopen(c_l_X_txt.c_str(), "w");
    FilePosition_right_X = std::fopen(c_r_X_txt.c_str(), "w");
    std::cout << "Start Writing Census Left and Right..." << std::endl;
    for (sint32 i = 0; i < height * width; i++)
    {
        std::fprintf(FilePosition_left_d, "%d\n", census_left[i]);
        std::fprintf(FilePosition_right_d, "%d\n", census_right[i]);
        std::fprintf(FilePosition_left_X, "%08X\n", census_left[i]);
        std::fprintf(FilePosition_right_X, "%08X\n", census_right[i]);
    }
    std::fclose(FilePosition_left_d);
    std::fclose(FilePosition_right_d);
    std::fclose(FilePosition_left_X);
    std::fclose(FilePosition_right_X);
    std::cout << "Writing Census Left and Right Finished!" << std::endl;

    // Save origin cost
    std::FILE *FilePosition_cost_d;
    std::FILE *FilePosition_cost_X;
    std::string cost_init_d_txt = cwd_ + "awesome-sgbm/Data/FPGA_proc/cost/cost_init_d.txt";
    std::string cost_init_X_txt = cwd_ + "awesome-sgbm/Data/FPGA_proc/cost/cost_init_X.txt";
    FilePosition_cost_d = std::fopen(cost_init_d_txt.c_str(), "w");
    FilePosition_cost_X = std::fopen(cost_init_X_txt.c_str(), "w");
    std::cout << "Start Writing Census Left and Right..." << std::endl;
    for (sint32 i = 0; i < height * width; i++)
    {
        for (sint32 j = 0; j < disp_range; j++)
        {
            if (j == disp_range - 1)
            {
                std::fprintf(FilePosition_cost_d, "%d\n", cost_init[i * disp_range + j]);
                std::fprintf(FilePosition_cost_X, "%02X\n", cost_init[i * disp_range + j]);
                continue;
            }
            std::fprintf(FilePosition_cost_d, "%d\t", cost_init[i * disp_range + j]);
            std::fprintf(FilePosition_cost_X, "%02X\t", cost_init[i * disp_range + j]);
        }
    }
    std::fclose(FilePosition_cost_d);
    std::fclose(FilePosition_cost_X);
    std::cout << "Writing Origin Cost Finished!" << std::endl;

    // Save aggregation cost
    std::FILE *FilePosition_aggr_lr_d;
    std::FILE *FilePosition_aggr_rl_d;
    std::FILE *FilePosition_aggr_lr_X;
    std::FILE *FilePosition_aggr_rl_X;
    std::string aggr_lr_d_txt = cwd_ + "awesome-sgbm/Data/FPGA_proc/aggr/aggr_lr_d.txt";
    std::string aggr_rl_d_txt = cwd_ + "awesome-sgbm/Data/FPGA_proc/aggr/aggr_rl_d.txt";
    std::string aggr_lr_X_txt = cwd_ + "awesome-sgbm/Data/FPGA_proc/aggr/aggr_lr_X.txt";
    std::string aggr_rl_X_txt = cwd_ + "awesome-sgbm/Data/FPGA_proc/aggr/aggr_rl_X.txt";
    FilePosition_aggr_lr_d = std::fopen(aggr_lr_d_txt.c_str(), "w");
    FilePosition_aggr_rl_d = std::fopen(aggr_rl_d_txt.c_str(), "w");
    FilePosition_aggr_lr_X = std::fopen(aggr_lr_X_txt.c_str(), "w");
    FilePosition_aggr_rl_X = std::fopen(aggr_rl_X_txt.c_str(), "w");
    std::cout << "Start Writing Census Left and Right..." << std::endl;
    for (sint32 i = 0; i < height * width; i++)
    {
        for (sint32 j = 0; j < disp_range; j++)
        {
            if (j == disp_range - 1)
            {
                std::fprintf(FilePosition_aggr_lr_d, "%d\n", cost_aggr_lr[i * disp_range + j]);
                std::fprintf(FilePosition_aggr_lr_X, "%08X\n", cost_aggr_lr[i * disp_range + j]);
                std::fprintf(FilePosition_aggr_rl_d, "%d\n", cost_aggr_rl[i * disp_range + j]);
                std::fprintf(FilePosition_aggr_rl_X, "%08X\n", cost_aggr_rl[i * disp_range + j]);
                continue;
            }
            std::fprintf(FilePosition_aggr_lr_d, "%d\t", cost_aggr_lr[i * disp_range + j]);
            std::fprintf(FilePosition_aggr_lr_X, "%08X\t", cost_aggr_lr[i * disp_range + j]);
            std::fprintf(FilePosition_aggr_rl_d, "%d\t", cost_aggr_rl[i * disp_range + j]);
            std::fprintf(FilePosition_aggr_rl_X, "%08X\t", cost_aggr_rl[i * disp_range + j]);
        }
    }
    std::fclose(FilePosition_aggr_lr_d);
    std::fclose(FilePosition_aggr_lr_X);
    std::fclose(FilePosition_aggr_rl_d);
    std::fclose(FilePosition_aggr_rl_X);

    // Save my disparity
    std::FILE *FilePosition_my_disp;
    std::string my_disparity_txt = cwd_ + "awesome-sgbm/Data/FPGA_proc/my_disparity.txt";
    FilePosition_my_disp = std::fopen(my_disparity_txt.c_str(), "w");
    std::cout << "Start Writing My Disparity..." << std::endl;
    for (sint32 i = 0; i < height * width; i++)
    {
        std::fprintf(FilePosition_my_disp, "%08X\n", my_disparity[i]);
    }
    std::fclose(FilePosition_my_disp);

    cv::namedWindow("视差图", 1);
    cv::namedWindow("视差图TEMP!", 1);
    cv::namedWindow("视差图-伪彩", 1);
    cv::namedWindow("视差图-伪彩TEMP!", 1);
    cv::imshow("视差图", disp_mat);
    cv::imshow("视差图TEMP!", disp_temp_mat);

    cv::Mat disp_color;
    applyColorMap(disp_mat, disp_color, cv::COLORMAP_JET);
    cv::imshow("视差图-伪彩", disp_color);
    cv::Mat disp_temp_color;
    applyColorMap(disp_temp_mat, disp_temp_color, cv::COLORMAP_JET);
    cv::imshow("视差图-伪彩TEMP!", disp_temp_color);

    // 保存结果bmp
    std::string disp_map_path = argc[2];
    disp_map_path += ".d.bmp";
    std::string disp_color_map_path = argc[2];
    disp_color_map_path += ".c.bmp";
    cv::imwrite(disp_map_path, disp_mat);
    cv::imwrite(disp_color_map_path, disp_color);

    cv::waitKey(0);

    // ···············································································//
    //  释放内存
    delete[] disparity;
    disparity = nullptr;
    delete[] bytes_left;
    bytes_left = nullptr;
    delete[] bytes_right;
    bytes_right = nullptr;

    return 1;
}
