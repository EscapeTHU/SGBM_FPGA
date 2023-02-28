/* -*-c++-*- SemiGlobalMatching - Copyright (C) 2022.
 * Author	: EscapeTHU
 */
#include <SemiGlobalMatching.h>
#include <opencv2/opencv.hpp>
#include <fstream>
#include <stdio.h>
#include <unistd.h>
#include <vector>
#include <iostream>
#include <sstream>
#include <iomanip>
#include <cstring>

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

    std::string cencus_in_left = path_left;
    std::string cencus_in_right = path_right;

    // Open input file
    std::ifstream input_L(cencus_in_left);
    std::ifstream input_R(cencus_in_right);

    if (!input_L || !input_R)
    {
        std::cerr << "Failed to open input file " << \
        cencus_in_left  << "or " << cencus_in_right  \
        << std::endl;
        return 1;
    }

    const sint32 width = 640;
    const sint32 height = 480;
    std::cout << "width of input picture == " << width << std::endl;
    std::cout << "height of input picture == " << height << std::endl;

        // Process each row of input data
    std::string line;
    uint32 line_val;
    // the graydata of the left and right image
    auto cencus_left = new uint32[uint32(width * height)]();
    auto cencus_right = new uint32[uint32(width * height)]();
    for (int i = 0; i < width * height; i++)
    {
        std::getline(input_L, line);
        sscanf(line.c_str(), "%x", &cencus_left[i]);
        std::getline(input_R, line);
        sscanf(line.c_str(), "%x", &cencus_right[i]);
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
    if (atoi(argc[5]) == 3)
        sgm_option.census_size = SemiGlobalMatching::Census3x3;
    else if (atoi(argc[5]) == 5)
        sgm_option.census_size = SemiGlobalMatching::Census5x5;
    else if (atoi(argc[5]) == 7)
        sgm_option.census_size = SemiGlobalMatching::Census7x7;
    else
        sgm_option.census_size = SemiGlobalMatching::Census9x7;
    // 一致性检查
    sgm_option.is_check_lr = false;
    sgm_option.lrcheck_thres = 1.0f;
    // 唯一性约束
    sgm_option.is_check_unique = false;
    sgm_option.uniqueness_ratio = 0.99;
    // 剔除小连通区
    sgm_option.is_remove_speckles = false;
    sgm_option.min_speckle_aera = 50;
    // 惩罚项P1、P2
    sgm_option.p1 = 10;
    sgm_option.p2_init = 150;
    // 视差图填充
    sgm_option.is_fill_holes = false;

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
    if (!sgm.Match(cencus_left, cencus_right, disparity, disparity_temp))
    {
        std::cout << "SGM匹配失败！" << std::endl;
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
    std::string disp_map_path = "./Data/cone_big/census_in";
    disp_map_path += ".d.bmp";
    std::string disp_color_map_path = "./Data/cone_big/census_in";
    disp_color_map_path += ".c.bmp";
    cv::imwrite(disp_map_path, disp_mat);
    cv::imwrite(disp_color_map_path, disp_color);

    cv::waitKey(0);

    // ···············································································//
    //  释放内存
    delete[] disparity;
    disparity = nullptr;
    delete[] cencus_left;
    cencus_left = nullptr;
    delete[] cencus_right;
    cencus_right = nullptr;

    return 1;
}
