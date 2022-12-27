/* -*-c++-*- SemiGlobalMatching - Copyright (C) 2020.
* Author	: Ethan Li <ethan.li.whu@gmail.com>
* https://github.com/ethan-li-coding/SemiGlobalMatching
*/
#include<SemiGlobalMatching.h>
#include<opencv2/opencv.hpp>

//#include<pcl/io/pcd_io.h>
//#include<pcl/point_cloud.h>
//#include<pcl/point_types.h>
//#include<pcl/common/common.h>
//#include<pcl/filters/passthrough.h>
//#include<pcl/filters/statistical_outlier_removal.h>
//#include<pcl/filters/radius_outlier_removal.h>
//#include<pcl/visualization/cloud_viewer.h>

const double camera_scale = 1000;

//void disp2pcd(cv::Mat disp,std::string cloud_save_path);



int main(int argv, char** argc)
{
  if(argv < 3)
   {
     std::cout<<"please input the left and right image path..."<<std::endl;
     return -1;
   }
  
   //read image
   std::string path_left = argc[1];
   std::string path_right = argc[2];
   
   cv::Mat img_left_c = cv::imread(path_left,cv::IMREAD_COLOR);
   cv::Mat img_left = cv::imread(path_left,cv::IMREAD_GRAYSCALE);
   cv::Mat img_right = cv::imread(path_right,cv::IMREAD_GRAYSCALE);
   
   cv::namedWindow("img_left_c",1);
   cv::imshow("img_left_c",img_left_c);

   cv::waitKey(30);

   cv::namedWindow("img_left",1);
   cv::imshow("img_left",img_left);

   cv::waitKey(30);

   cv::namedWindow("img_right",1);
   cv::imshow("img_right",img_right);

   cv::waitKey(30);
  
   
   if (img_left.data == nullptr || img_right.data == nullptr) {
        std::cout << "fail to read images" << std::endl;
        return -1;
   }
   if (img_left.rows != img_right.rows || img_left.cols != img_right.cols) {
        std::cout << "img_left.size not equals img_right" << std::endl;
        return -1;
   }

   const sint32 width = static_cast<uint32>(img_left.cols);
   const sint32 height = static_cast<uint32>(img_right.rows);

   //the graydata of the left and right image
   auto bytes_left = new uint8[width * height];
   auto bytes_right = new uint8[width * height];
   for (int i = 0; i < height; i++) {
       for (int j = 0; j < width; j++) {
            bytes_left[i * width + j] = img_left.at<uint8>(i, j);
            bytes_right[i * width + j] = img_right.at<uint8>(i, j);
       }
   }
    // SGM匹配参数设计
    SemiGlobalMatching::SGMOption sgm_option;
    // 聚合路径数
    sgm_option.num_paths = 8;
    // 候选视差范围
    sgm_option.min_disparity = argv < 4 ? 0 : atoi(argc[3]);
    sgm_option.max_disparity = argv < 5 ? 64 : atoi(argc[4]);
    std::cout<<"argc[3]== "<<argc[3]<<std::endl;
    std::cout<<"argc[4]== "<<argc[4]<<std::endl;
    std::cout<<"sgm_option.min_disparity == "<<sgm_option.min_disparity<<std::endl;
    std::cout<<"sgm_option.max_disparity == "<<sgm_option.max_disparity<<std::endl;
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
    sgm_option.is_fill_holes = false;

    // 定义SGM匹配类实例
    SemiGlobalMatching sgm;
    
    // 初始化
    if (!sgm.Initialize(width, height, sgm_option)) {
        std::cout << "SGM初始化失败！" << std::endl;
        return -2;
    }
    
    // 匹配
    auto disparity = new float32[uint32(width * height)]();
    if (!sgm.Match(bytes_left, bytes_right, disparity)) {
        std::cout << "SGM匹配失败！" << std::endl;
        return -2;
    }

    // 显示视差图
    cv::Mat disp_mat = cv::Mat(height, width, CV_8UC1);
    float min_disp = width, max_disp = -width;
    for (sint32 i = 0; i < height; i++) {
        for (sint32 j = 0; j < width; j++) {
            const float32 disp = disparity[i * width + j];
            if (disp != Invalid_Float) {
                min_disp = std::min(min_disp, disp);
                max_disp = std::max(max_disp, disp);
            }
        }
    }
    for (sint32 i = 0; i < height; i++) {
        for (sint32 j = 0; j < width; j++) {
            const float32 disp = disparity[i * width + j];
            if (disp == Invalid_Float) {
                disp_mat.data[i * width + j] = 0;
            }
            else {
                disp_mat.data[i * width + j] = static_cast<uchar>((disp - min_disp) / (max_disp - min_disp) * 255);
            }
        }
    }
    
    cv::namedWindow("视差图",1);
    cv::namedWindow("视差图-伪彩",1);
    cv::imshow("视差图", disp_mat);    

    cv::Mat disp_color;
    applyColorMap(disp_mat, disp_color, cv::COLORMAP_JET);
    cv::imshow("视差图-伪彩", disp_color);
   
    // 保存结果
    std::string disp_map_path = argc[1]; disp_map_path += ".d.bmp";
    std::string disp_color_map_path = argc[1]; disp_color_map_path += ".c.bmp";
    cv::imwrite(disp_map_path, disp_mat);
    cv::imwrite(disp_color_map_path, disp_color);

    cv::waitKey();

   //···············································································//
   // 释放内存
   delete[] disparity;
   disparity = nullptr;
   delete[] bytes_left;
   bytes_left = nullptr;
   delete[] bytes_right;
   bytes_right = nullptr;

   //将视差图结合基线与相机的标定参数，转换为点云数据保存到本地
   //std::string cloud_save_path = argc[1];
   //cloud_save_path +=".p.pcd";
   //disp2pcd(disp_mat,cloud_save_path);
   
   return 1;
}


//left:
//width: 640, height: 400
//distortion_model: KANNALA_BRANDT
//D: -0.14889299848373000,-0.04364167748312290,0.03435832570726938,-0.01064062776854229,0.00000000000000000,
//K: 443.79692612349492720,0.00000000000000000,293.49938427510551264,0.00000000000000000,443.41192442172251731,202.02520621228134701,0.00000000000000000,0.00000000000000000,1.00000000000000000,
//R: 0.99995247102313090,-0.00212421717650776,-0.00951542937136942,0.00214685787750808,0.99999488754678378,0.00236978512716580,0.00951034678591017,-0.00239010076820710,0.99995191920528326,
//P: 442.05185684172238325,0.00000000000000000,158.16831588745117188,0.00000000000000000,0.00000000000000000,442.05185684172238325,216.55125045776367188,0.00000000000000000,0.00000000000000000,0.00000000000000000,1.00000000000000000,0.00000000000000000,

//right:
//width: 640, height: 400
//distortion_model: KANNALA_BRANDT
//D: -0.14697665095661802,-0.07324936449923376,0.10467077488904218,-0.05803606929814879,0.00000000000000000,
//K: 440.90950841155984108,0.00000000000000000,324.59837182329016514,0.00000000000000000,440.69178926172230604,204.82011592645241649,0.00000000000000000,0.00000000000000000,1.00000000000000000,
//R: 0.99986835144176900,-0.00297108675530597,-0.01595156508344964,0.00293362984971600,0.99999288594079405,-0.00237105118181846,0.01595849620183366,0.00232394304887038,0.99986995438791015,
//P: 442.05185684172238325,0.00000000000000000,158.16831588745117188,-35322.48634352167573525,0.00000000000000000,442.05185684172238325,216.55125045776367188,0.00000000000000000,0.00000000000000000,0.00000000000000000,1.00000000000000000,0.00000000000000000,
/*
void disp2pcd(cv::Mat disp,std::string cloud_save_path)
{
   if(disp.data == nullptr)
   {
     std::cout<<"disp is empty! Please check!"<<std::endl;
     return;
   }
   cv::Size s;
   s.height = disp.rows;
   s.width = disp.cols;
   
   #if 0
   //left camera paras
   double fx_1 = 443.79692612349492720;
   double fy_1 = 443.41192442172251731;
   double u_1 = 293.49938427510551264;
   double v_1 = 202.02520621228134701;
   
   //right camera paras
   double fx_2 = 440.90950841155984108;
   double fy_2 = 440.69178926172230604;
   double u_2 = 324.59837182329016514;
   double v_2 = 204.82011592645241649;
   #endif
   
   #if 1
    //left camera paras
   double fx_1 = 442.05185684172238325;
   double fy_1 = 442.05185684172238325;
   double u_1 = 158.16831588745117188;
   double v_1 = 216.55125045776367188;
   
   //right camera paras
   double fx_2 =  442.05185684172238325;
   double fy_2 = 442.05185684172238325;
   double u_2 = 158.16831588745117188;
   double v_2 = 216.55125045776367188;
   #endif
   
   double base = 80.0/camera_scale;

   cv::Mat K1 = (cv::Mat_<double>(3,3)<< fx_1, 0, u_1, 0, fy_1, v_1, 0, 0, 1);
   cv::Mat K2 = (cv::Mat_<double>(3,3)<< fx_2, 0, u_2, 0, fy_2, v_2, 0, 0, 1);
   cv::Mat distort1 = (cv::Mat_<double>(5,1)<<0,0,0,0,0);
 
  cv::Mat R = cv::Mat::eye(3, 3, CV_64FC1);
  cv::Mat t = (cv::Mat_<double>(3, 1) << -base, 0, 0);
      
  cv::Mat R1 = cv::Mat::eye(3, 3, CV_64FC1);
  cv::Mat R2 = cv::Mat::eye(3, 3, CV_64FC1); 
  cv::Mat P1 = cv::Mat::eye(3, 4, CV_64FC1); 
  cv::Mat P2 = cv::Mat::eye(3, 4, CV_64FC1); 
  cv::Mat Q_ = cv::Mat::eye(4, 4, CV_64FC1);
  cv::stereoRectify(K1, distort1, K2, distort1, s, R, t, R1, R2, P1, P2, Q_); 

  cv::Mat image3D(s,CV_32FC3);
  cv::reprojectImageTo3D(disp,image3D,Q_,false);

  pcl::PointCloud<pcl::PointXYZ>::Ptr cloud(new pcl::PointCloud<pcl::PointXYZ>);
  pcl::PointXYZ p;
  cloud->width = (s.height)*(s.width);
  cloud->height = 1;
  cloud->points.reserve(cloud->width*cloud->height);
  
  //form 40 to width - 40: to remove outlire on the border
  for(int v = 0; v < s.height; v++)
  {
    for(int u = 0; u < s.width; u++)
    {
       cv::Vec3f pv = image3D.ptr<cv::Vec3f>(v)[u];
       p.x = pv[0];
       p.y = pv[1];
       p.z = pv[2];
       if(p.z < 2)
       {
         cloud->points.push_back(p);
       }   
    }
    
  }
  cloud->width = cloud->points.size();

  //滤波后的点云
  //pcl::PointCloud<pcl::PointXYZ>::Ptr cloud_filtered_passthrough(new pcl::PointCloud<pcl::PointXYZ>);
  
  //pcl::PointXYZ minPt,maxPt;
  //pcl::getMinMax3D(*cloud,minPt,maxPt);
  
  //创建直通滤波器对象
  //pcl::PassThrough<pcl::PointXYZ> pass; 
  //pass.setInputCloud(cloud);
  //pass.setFilterFieldName("z");
  //pass.setFilterLimits(minPt.z + 0.1,maxPt.z - 1.0); //设置在过滤字段上的范围；
  //pass.setFilterLimits(0.1, 1.5); //设置在过滤字段上的范围；
  //pass.setFilterLimitsNegative(false); //设置保留范围内(false)的还是过滤掉范围内的(true)
  //pass.filter(*cloud_filtered_passthrough);

  //创建统计滤波器对象
  //pcl::PointCloud<pcl::PointXYZ>::Ptr cloud_filtered_statistic(new pcl::PointCloud<pcl::PointXYZ>);
  //pcl::StatisticalOutlierRemoval<pcl::PointXYZ> sor;//创建滤波器对象
 // sor.setInputCloud(cloud_filtered_passthrough); //设置带滤波的点云
  //sor.setMeanK(90);//设置在进行统计时考虑查询点邻近点数
  //sor.setStddevMulThresh(1.0);//设置判断是否为离群点的阈值
  //sor.filter(*cloud_filtered_statistic);
  
  //sor.setNegative (false); //这里如果为true，表示保存滤除掉的外部点，否则为内部点

  //创建RadiusOutlierRemoval
  //pcl::PointCloud<pcl::PointXYZ>::Ptr cloud_filtered_radius(new pcl::PointCloud<pcl::PointXYZ>);
  //pcl::RadiusOutlierRemoval<pcl::PointXYZ> radius;
  //radius.setInputCloud(cloud_filtered_statistic);
  //radius.setRadiusSearch(0.02);
  //radius.setMinNeighborsInRadius(90);
  //radius.setNegative(false);
  //radius.filter(*cloud_filtered_radius);

  
  pcl::io::savePCDFileASCII(cloud_save_path,*cloud);

  pcl::visualization::CloudViewer viewer("cloud viewer.");
  viewer.showCloud(cloud);
  while(!viewer.wasStopped())
  {

  }
}
*/



