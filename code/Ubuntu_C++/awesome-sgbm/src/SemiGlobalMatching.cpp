/* -*-c++-*- SemiGlobalMatching - Copyright (C) 2022.
* Author	: EscapeTHU
*/
#include "SemiGlobalMatching.h"
#include "sgm_util.h"
#include <algorithm>
#include <vector>
#include <cassert>
#include <math.h>
#include <iostream>

SemiGlobalMatching::SemiGlobalMatching(): width_(0), height_(0), img_left_(nullptr), img_right_(nullptr),
                                          census_left_(nullptr), census_right_(nullptr),
                                          cost_init_(nullptr), cost_aggr_(nullptr),
                                          cost_aggr_1_(nullptr), cost_aggr_2_(nullptr),
                                          cost_aggr_3_(nullptr), cost_aggr_4_(nullptr),
                                          cost_aggr_5_(nullptr), cost_aggr_6_(nullptr),
                                          cost_aggr_7_(nullptr), cost_aggr_8_(nullptr),
                                          disp_left_(nullptr), disp_right_(nullptr),
                                          is_initialized_(false)
{
}


SemiGlobalMatching::~SemiGlobalMatching()
{
    Release();
    is_initialized_ = false;
}

bool SemiGlobalMatching::Initialize(const sint32& width, const sint32& height, const SGMOption& option)
{
    // ··· 赋值
    
	// 影像尺寸
    width_ = width;
    height_ = height;
    // SGM参数
    option_ = option;

    if(width == 0 || height == 0) {
        return false;
    }

    //··· 开辟内存空间

    // census值（左右影像）
    const sint32 img_size = width * height;
    if (option.census_size == Census5x5) {
        census_left_ = new uint32[img_size]();
        census_right_ = new uint32[img_size]();
    }
    else {
        census_left_ = new uint64[img_size]();
        census_right_ = new uint64[img_size]();
    }

    // 视差范围
    const sint32 disp_range = option.max_disparity - option.min_disparity;
    if (disp_range <= 0) {
        return false;
    }

    // 匹配代价（初始/聚合）
    const sint32 size = width * height * disp_range;
    cost_init_  = new uint8[size]();
    cost_aggr_  = new uint16[size]();
    cost_aggr_1_ = new uint8[size]();
    cost_aggr_2_ = new uint8[size]();
    cost_aggr_3_ = new uint8[size]();
    cost_aggr_4_ = new uint8[size]();
    cost_aggr_5_ = new uint8[size]();
    cost_aggr_6_ = new uint8[size]();
    cost_aggr_7_ = new uint8[size]();
    cost_aggr_8_ = new uint8[size]();
    cost_aggr_temp_ = new uint8[size]();

    // 视差图
    disp_left_ = new float32[img_size]();
    disp_right_ = new float32[img_size]();
    disp_my_ = new uint32[img_size]();
    disp_temp_ = new float32[img_size]();

    is_initialized_ = census_left_ && census_right_ && cost_init_ && cost_aggr_ && disp_left_;

    return is_initialized_;
}


void SemiGlobalMatching::Release()
{
    // 释放内存
    SAFE_DELETE(census_left_);
    SAFE_DELETE(census_right_);
    SAFE_DELETE(cost_init_);
    SAFE_DELETE(cost_aggr_);
    SAFE_DELETE(cost_aggr_1_);
    SAFE_DELETE(cost_aggr_2_);
    SAFE_DELETE(cost_aggr_3_);
    SAFE_DELETE(cost_aggr_4_);
    SAFE_DELETE(cost_aggr_5_);
    SAFE_DELETE(cost_aggr_6_);
    SAFE_DELETE(cost_aggr_7_);
    SAFE_DELETE(cost_aggr_8_);
    SAFE_DELETE(cost_aggr_temp_);
    SAFE_DELETE(disp_left_);
    SAFE_DELETE(disp_right_);
    SAFE_DELETE(disp_temp_);
}

bool SemiGlobalMatching::GetCensus(uint32* census_left, uint32* census_right)
{
    if (!is_initialized_) {
        return false;
    }
    const sint32 img_size = width_ * height_;
    memcpy(census_left, census_left_, height_ * width_ * sizeof(uint32));
    memcpy(census_right, census_right_, height_ * width_ * sizeof(uint32));
    return true;
}

bool SemiGlobalMatching::GetOriginCost(uint8* cost_init)
{
    if (!is_initialized_) {
        return false;
    }
    const sint32 size = width_ * height_ * (option_.max_disparity - option_.min_disparity);
    memcpy(cost_init, cost_init_, size * sizeof(uint8));
    return true;
}

bool SemiGlobalMatching::GetAggrCost(uint8* cost_aggr, int sign)
{
    if (!is_initialized_) {
        return false;
    }
    const sint32 size = width_ * height_ * (option_.max_disparity - option_.min_disparity);
    switch (sign) {
        case 1: memcpy(cost_aggr, cost_aggr_1_, size * sizeof(uint8)); break;
        case 2: memcpy(cost_aggr, cost_aggr_2_, size * sizeof(uint8)); break;
        case 3: memcpy(cost_aggr, cost_aggr_3_, size * sizeof(uint8)); break;
        case 4: memcpy(cost_aggr, cost_aggr_4_, size * sizeof(uint8)); break;
        case 5: memcpy(cost_aggr, cost_aggr_5_, size * sizeof(uint8)); break;
        case 6: memcpy(cost_aggr, cost_aggr_6_, size * sizeof(uint8)); break;
        case 7: memcpy(cost_aggr, cost_aggr_7_, size * sizeof(uint8)); break;
        case 8: memcpy(cost_aggr, cost_aggr_8_, size * sizeof(uint8)); break;
    }
    return true;
}

bool SemiGlobalMatching::GetDisparity(uint32* my_disp)
{
    if (!is_initialized_) {
        return false;
    }
    const sint32 img_size = width_ * height_;
    memcpy(my_disp, disp_my_, height_ * width_ * sizeof(uint32));
    return true;
}

bool SemiGlobalMatching::Match(const uint8* img_left, const uint8* img_right, float32* disp_left, float32* disp_temp)
{
    if(!is_initialized_) {
        return false;
    }
    if (img_left == nullptr || img_right == nullptr) {
        return false;
    }

    img_left_ = img_left;
    img_right_ = img_right;

    // census变换
    CensusTransform();
    // Cencus 3x3 dont apply to subsequent operations 
    // wait for modify
    if (option_.census_size == Census3x3)
        option_.census_size = Census5x5;
    

    // 代价计算
    ComputeCost();

    // 代价聚合
    // CostAggregation();

    // 视差计算
    ComputeDisparity();
    ComputeDisparity_init();

    // 左右一致性检查
    if (option_.is_check_lr) {
        // 视差计算（右影像）
        ComputeDisparityRight();
        // 一致性检查
        LRCheck();
    }

    // 移除小连通区
    if (option_.is_remove_speckles) {
        sgm_util::RemoveSpeckles(disp_left_, width_, height_, 1, option_.min_speckle_aera, Invalid_Float);
    }

    // 视差填充
	if(option_.is_fill_holes) {
		FillHolesInDispMap();
	}

    // 中值滤波
    if (option_.median_filter)
    {
        sgm_util::MedianFilter(disp_left_, disp_left_, width_, height_, 3);
    } 

    // 输出视差图
    memcpy(disp_left, disp_left_, height_ * width_ * sizeof(float32));
    memcpy(disp_temp, disp_temp_, height_ * width_ * sizeof(float32));

	return true;
}

bool SemiGlobalMatching::Match(const uint32* cencus_left, const uint32* cencus_right, float32* disp_left, float32* disp_temp)
{
    if(!is_initialized_) {
        return false;
    }
    if (cencus_left == nullptr || cencus_right == nullptr) {
        return false;
    }

    // census变换
    Cencus_in(cencus_left, cencus_right);
    
    // 代价计算
    ComputeCost();

    // 代价聚合
    // CostAggregation();

    // 视差计算
    ComputeDisparity();

    // 中值滤波
    // sgm_util::MedianFilter(disp_left_, disp_left_, width_, height_, 3);

    // 输出视差图
    memcpy(disp_left, disp_left_, height_ * width_ * sizeof(float32));
    memcpy(disp_temp, disp_temp_, height_ * width_ * sizeof(float32));

	return true;
}


bool SemiGlobalMatching::Reset(const uint32& width, const uint32& height, const SGMOption& option)
{
    // 释放内存
    Release();

    // 重置初始化标记
    is_initialized_ = false;

    // 初始化
    return Initialize(width, height, option);
}

void SemiGlobalMatching::CensusTransform() const
{
	// 左右影像census变换
    if (option_.census_size == Census3x3) {
        sgm_util::census_transform_3x3(img_left_, static_cast<uint32*>(census_left_), width_, height_);
        sgm_util::census_transform_3x3(img_right_, static_cast<uint32*>(census_right_), width_, height_);
    } else if (option_.census_size == Census5x5) {
        sgm_util::census_transform_5x5(img_left_, static_cast<uint32*>(census_left_), width_, height_);
        sgm_util::census_transform_5x5(img_right_, static_cast<uint32*>(census_right_), width_, height_);
    } else if (option_.census_size == Census7x7) {
        sgm_util::census_transform_7x7(img_left_, static_cast<uint64*>(census_left_), width_, height_);
        sgm_util::census_transform_7x7(img_right_, static_cast<uint64*>(census_right_), width_, height_);
    } else {
        sgm_util::census_transform_9x7(img_left_, static_cast<uint64*>(census_left_), width_, height_);
        sgm_util::census_transform_9x7(img_right_, static_cast<uint64*>(census_right_), width_, height_);
    }
}

void SemiGlobalMatching::Cencus_in(const uint32* cencus_left, const uint32* cencus_right) const
{
    sgm_util::Cencus_in_assign(cencus_left, static_cast<uint32*>(census_left_), width_, height_);
    sgm_util::Cencus_in_assign(cencus_right, static_cast<uint32*>(census_right_), width_, height_);
}

void SemiGlobalMatching::ComputeCost() const
{
    const sint32& min_disparity = option_.min_disparity;
    const sint32& max_disparity = option_.max_disparity;
    const sint32 disp_range = max_disparity - min_disparity;
    if (disp_range <= 0) {
        return;
    }


	// 计算代价（基于Hamming距离）
    for (sint32 i = 0; i < height_; i++) {
        for (sint32 j = 0; j < width_; j++) {
            // 逐视差计算代价值
        	for (sint32 d = min_disparity; d < max_disparity; d++) {
                auto& cost = cost_init_[i * width_ * disp_range + j * disp_range + (d - min_disparity)];
                if (j - d < 0 || j - d >= width_) {
                    cost = UINT8_MAX;
                    continue;
                }
                if (option_.census_size == Census3x3 || option_.census_size == Census5x5) {
                    // 左影像census值
                    const auto& census_val_l = static_cast<uint32*>(census_left_)[i * width_ + j];
                    // 右影像对应像点的census值
                    const auto& census_val_r = static_cast<uint32*>(census_right_)[i * width_ + j - d];
                    // 计算匹配代价
                    cost = sgm_util::Hamming32(census_val_l, census_val_r);
                }
        		else {
                    const auto& census_val_l = static_cast<uint64*>(census_left_)[i * width_ + j];
                    const auto& census_val_r = static_cast<uint64*>(census_right_)[i * width_ + j - d];
                    cost = sgm_util::Hamming64(census_val_l, census_val_r);
                }
            }
        }
    }
}

void SemiGlobalMatching::CostAggregation() const
{
    // 路径聚合
    // 1、左->右/右->左
    // 2、上->下/下->上
    // 3、左上->右下/右下->左上
    // 4、右上->左上/左下->右上
    //
    // ↘ ↓ ↙   5  3  7
    // →    ←	 1    2
    // ↗ ↑ ↖   8  4  6
    //
    const auto& min_disparity = option_.min_disparity;
    const auto& max_disparity = option_.max_disparity;
    assert(max_disparity > min_disparity);

    const sint32 size = width_ * height_ * (max_disparity - min_disparity);
    if(size <= 0) {
        return;
    }

    const auto& P1 = option_.p1;
    const auto& P2_Int = option_.p2_init;
    
    // std::cout << "The option num path is: " << option_.num_paths << std::endl;
    

    if (option_.num_paths == 4 || option_.num_paths == 8) {
        // 左右聚合
        sgm_util::CostAggregateLeftRight(img_left_, width_, height_, min_disparity, max_disparity, P1, P2_Int, cost_init_, cost_aggr_1_, true);
        sgm_util::CostAggregateLeftRight(img_left_, width_, height_, min_disparity, max_disparity, P1, P2_Int, cost_init_, cost_aggr_2_, false);
        // 上下聚合
		sgm_util::CostAggregateUpDown(img_left_, width_, height_, min_disparity, max_disparity, P1, P2_Int, cost_init_, cost_aggr_3_, true);
        sgm_util::CostAggregateUpDown(img_left_, width_, height_, min_disparity, max_disparity, P1, P2_Int, cost_init_, cost_aggr_4_, false);
    }

    if (option_.num_paths == 8) {
        // 对角线1聚合
        sgm_util::CostAggregateDagonal_1(img_left_, width_, height_, min_disparity, max_disparity, P1, P2_Int, cost_init_, cost_aggr_5_, true);
        sgm_util::CostAggregateDagonal_1(img_left_, width_, height_, min_disparity, max_disparity, P1, P2_Int, cost_init_, cost_aggr_6_, false);
        // 对角线2聚合
        sgm_util::CostAggregateDagonal_2(img_left_, width_, height_, min_disparity, max_disparity, P1, P2_Int, cost_init_, cost_aggr_7_, true);
        sgm_util::CostAggregateDagonal_2(img_left_, width_, height_, min_disparity, max_disparity, P1, P2_Int, cost_init_, cost_aggr_8_, false);
    }

    // 把4/8个方向加起来
    for (sint32 i = 0; i < size; i++) {
        if (option_.num_paths == 4 || option_.num_paths == 8) {
            cost_aggr_[i] = cost_aggr_1_[i] + cost_aggr_2_[i] + cost_aggr_3_[i] + cost_aggr_4_[i];
            // cost_aggr_[i] = cost_aggr_1_[i] + cost_aggr_2_[i];
            // std::cout<<"Hello!"<<std::endl;
            // cost_aggr_[i] = cost_aggr_1_[i];
        }
        if (option_.num_paths == 8) {
            // std::cout<<"NO!"<<std::endl;
            cost_aggr_[i] += cost_aggr_5_[i] + cost_aggr_6_[i] + cost_aggr_7_[i] + cost_aggr_8_[i];
        }
    }
}

void SemiGlobalMatching::ComputeDisparity_init() const
{
    const sint32& min_disparity = option_.min_disparity;
    const sint32& max_disparity = option_.max_disparity;
    const sint32 disp_range = max_disparity - min_disparity;
    if (disp_range <= 0) {
        return;
    }
    
    const sint32 size = width_ * height_ * (max_disparity - min_disparity);
    if(size <= 0) {
        return;
    }
    for (sint32 i = 0; i < size; i++) {
        cost_aggr_temp_[i] = cost_aggr_1_[i] + cost_aggr_2_[i];
    }
    
    const auto disparity = disp_temp_;
    const auto cost_ptr = cost_aggr_;
    
    const sint32 width = width_;
    const sint32 height = height_;
    
    for (sint32 i = 0; i < height; i++) {
        for (sint32 j = 0; j < width; j++) {
            uint16 min_cost = UINT16_MAX;
            uint16 sec_min_cost = UINT16_MAX;
            sint32 best_disparity = 0;
            for (sint32 d = min_disparity; d < max_disparity; d++) {
                const sint32 d_idx = d - min_disparity;
                const auto& cost = cost_ptr[i*width*disp_range+j*disp_range+d_idx];
                if (min_cost>cost) {
                    min_cost = cost;
                    best_disparity = d;
                }
            }
            disparity[i*width+j] = static_cast<float32>(best_disparity);
        }
    }
}

void SemiGlobalMatching::ComputeDisparity() const
{
    const sint32& min_disparity = option_.min_disparity;
    const sint32& max_disparity = option_.max_disparity;
    const sint32 disp_range = max_disparity - min_disparity;
    if(disp_range <= 0) {
        return;
    }

    // 左影像视差图
    const auto disparity = disp_left_;
	// 左影像聚合代价数组
	// const auto cost_ptr = cost_aggr_;
	const auto cost_ptr = cost_init_;
	
	const auto my_disparity = disp_my_;

    const sint32 width = width_;
    const sint32 height = height_;
    const bool is_check_unique = option_.is_check_unique;
	const float32 uniqueness_ratio = option_.uniqueness_ratio;

	// 为了加快读取效率，把单个像素的所有代价值存储到局部数组里
    std::vector<uint16> cost_local(disp_range);
    
	// ---逐像素计算最优视差
	for (sint32 i = 0; i < height; i++) {
        for (sint32 j = 0; j < width; j++) {
            uint16 min_cost = UINT16_MAX;
            uint16 sec_min_cost = UINT16_MAX;
            sint32 best_disparity = 0;

            // ---遍历视差范围内的所有代价值，输出最小代价值及对应的视差值
            for (sint32 d = min_disparity; d < max_disparity; d++) {
	            const sint32 d_idx = d - min_disparity;
                const auto& cost = cost_local[d_idx] = cost_ptr[i * width * disp_range + j * disp_range + d_idx];
                if(min_cost > cost) {
                    min_cost = cost;
                    best_disparity = d;
                }
            }

            // if (is_check_unique) {
            //     // 再遍历一次，输出次最小代价值
            //     for (sint32 d = min_disparity; d < max_disparity; d++) {
            //         if (d == best_disparity) {
            //             // 跳过最小代价值
            //             continue;
            //         }
            //         const auto& cost = cost_local[d - min_disparity];
            //         sec_min_cost = std::min(sec_min_cost, cost);
            //     }

            //     // 判断唯一性约束
            //     // 若(min-sec)/min < min*(1-uniquness)，则为无效估计
            //     if (sec_min_cost - min_cost <= static_cast<uint16>(min_cost * (1 - uniqueness_ratio))) {
            //         disparity[i * width + j] = Invalid_Float;
            //         my_disparity[i * width + j] = UINT32_MAX;
            //         continue;
            //     }
            // }

            // ---子像素拟合
            // if (best_disparity == min_disparity || best_disparity == max_disparity - 1) {
            //     disparity[i * width + j] = Invalid_Float;
            //     my_disparity[i * width + j] = UINT32_MAX;
            //     continue;
            // }
            // 最优视差前一个视差的代价值cost_1，后一个视差的代价值cost_2
            const sint32 idx_1 = best_disparity - 1 - min_disparity;
            const sint32 idx_2 = best_disparity + 1 - min_disparity;
            const uint16 cost_1 = cost_local[idx_1];
            const uint16 cost_2 = cost_local[idx_2];
            // 解一元二次曲线极值
            const uint16 denom = std::max(1, cost_1 + cost_2 - 2 * min_cost);
            disparity[i * width + j] = static_cast<float32>(best_disparity) + static_cast<float32>(cost_1 - cost_2) / (denom * 2.0f);
            my_disparity[i * width + j] = static_cast<uint32>(best_disparity + static_cast<sint32>(cost_1-cost_2)/static_cast<sint32>(denom*2));
        }
    }
}

void SemiGlobalMatching::ComputeDisparityRight() const
{
    const sint32& min_disparity = option_.min_disparity;
    const sint32& max_disparity = option_.max_disparity;
    const sint32 disp_range = max_disparity - min_disparity;
    if (disp_range <= 0) {
        return;
    }

    // 右影像视差图
    const auto disparity = disp_right_;
    // 左影像聚合代价数组
	const auto cost_ptr = cost_aggr_;
	// const auto cost_ptr = cost_init_;

    const sint32 width = width_;
    const sint32 height = height_;
    const bool is_check_unique = option_.is_check_unique;
    const float32 uniqueness_ratio = option_.uniqueness_ratio;

    // 为了加快读取效率，把单个像素的所有代价值存储到局部数组里
    std::vector<uint16> cost_local(disp_range);

    // ---逐像素计算最优视差
    // 通过左影像的代价，获取右影像的代价
    // 右cost(xr,yr,d) = 左cost(xr+d,yl,d)
    for (sint32 i = 0; i < height; i++) {
        for (sint32 j = 0; j < width; j++) {
            uint16 min_cost = UINT16_MAX;
            uint16 sec_min_cost = UINT16_MAX;
            sint32 best_disparity = 0;

            // ---统计候选视差下的代价值
        	for (sint32 d = min_disparity; d < max_disparity; d++) {
                const sint32 d_idx = d - min_disparity;
        		const sint32 col_left = j + d;
        		if (col_left >= 0 && col_left < width) {
                    const auto& cost = cost_local[d_idx] = cost_ptr[i * width * disp_range + col_left * disp_range + d_idx];
                    if (min_cost > cost) {
                        min_cost = cost;
                        best_disparity = d;
                    }
        		}
                else {
                    cost_local[d_idx] = UINT16_MAX;
                }
            }

            if (is_check_unique) {
                // 再遍历一次，输出次最小代价值
                for (sint32 d = min_disparity; d < max_disparity; d++) {
                    if (d == best_disparity) {
                        // 跳过最小代价值
                        continue;
                    }
                    const auto& cost = cost_local[d - min_disparity];
                    sec_min_cost = std::min(sec_min_cost, cost);
                }

                // 判断唯一性约束
                // 若(min-sec)/min < min*(1-uniquness)，则为无效估计
                if (sec_min_cost - min_cost <= static_cast<uint16>(min_cost * (1 - uniqueness_ratio))) {
                    disparity[i * width + j] = Invalid_Float;
                    continue;
                }
            }
            
            // ---子像素拟合
            if (best_disparity == min_disparity || best_disparity == max_disparity - 1) {
                disparity[i * width + j] = Invalid_Float;
                continue;
            }

            // 最优视差前一个视差的代价值cost_1，后一个视差的代价值cost_2
            const sint32 idx_1 = best_disparity - 1 - min_disparity;
            const sint32 idx_2 = best_disparity + 1 - min_disparity;
            const uint16 cost_1 = cost_local[idx_1];
            const uint16 cost_2 = cost_local[idx_2];
            // 解一元二次曲线极值
            const uint16 denom = std::max(1, cost_1 + cost_2 - 2 * min_cost);
            disparity[i * width + j] = static_cast<float32>(best_disparity) + static_cast<float32>(cost_1 - cost_2) / (denom * 2.0f);
        }
    }
}

void SemiGlobalMatching::LRCheck()
{
    const sint32 width = width_;
    const sint32 height = height_;

    const float32& threshold = option_.lrcheck_thres;

	// 遮挡区像素和误匹配区像素
	auto& occlusions = occlusions_;
	auto& mismatches = mismatches_;
	occlusions.clear();
	mismatches.clear();

    // ---左右一致性检查
    for (sint32 i = 0; i < height; i++) {
        for (sint32 j = 0; j < width; j++) {
            
            // 左影像视差值
        	auto& disp = disp_left_[i * width + j];

			if(disp == Invalid_Float){
				mismatches.emplace_back(i, j);
				continue;
			}

            // 根据视差值找到右影像上对应的同名像素
        	const auto col_right = static_cast<sint32>(j - disp + 0.5);
            
        	if(col_right >= 0 && col_right < width) {

                // 右影像上同名像素的视差值
                const auto& disp_r = disp_right_[i * width + col_right];
                
        		// 判断两个视差值是否一致（差值在阈值内）
        		if (abs(disp - disp_r) > threshold) {
					// 区分遮挡区和误匹配区
					// 通过右影像视差算出在左影像的匹配像素，并获取视差disp_rl
					// if(disp_rl > disp) 
        			//		pixel in occlusions
					// else 
        			//		pixel in mismatches
					const sint32 col_rl = static_cast<sint32>(col_right + disp_r + 0.5);
					if(col_rl > 0 && col_rl < width){
						const auto& disp_l = disp_left_[i*width + col_rl];
						if(disp_l > disp) {
							occlusions.emplace_back(i, j);
						}
						else {
							mismatches.emplace_back(i, j);
						}
					}
					else{
						mismatches.emplace_back(i, j);
					}

                    // 让视差值无效
					disp = Invalid_Float;
                }
            }
            else{
                // 通过视差值在右影像上找不到同名像素（超出影像范围）
                disp = Invalid_Float;
				mismatches.emplace_back(i, j);
            }
        }
    }
}

void SemiGlobalMatching::FillHolesInDispMap()
{
	const sint32 width = width_;
	const sint32 height = height_;

	std::vector<float32> disp_collects;

	// 定义8个方向
	float32 pi = 3.1415926f;
	float32 angle1[8] = { pi, 3 * pi / 4, pi / 2, pi / 4, 0, 7 * pi / 4, 3 * pi / 2, 5 * pi / 4 };
	float32 angle2[8] = { pi, 5 * pi / 4, 3 * pi / 2, 7 * pi / 4, 0, pi / 4, pi / 2, 3 * pi / 4 };
	float32 *angle = angle1;

	float32* disp_ptr = disp_left_;
	for (sint32 k = 0; k < 3; k++) {
		// 第一次循环处理遮挡区，第二次循环处理误匹配区
		auto& trg_pixels = (k == 0) ? occlusions_ : mismatches_;
        if (trg_pixels.empty()) {
            continue;
        }
		std::vector<std::pair<sint32, sint32>> inv_pixels;
		if (k == 2) {
			//  第三次循环处理前两次没有处理干净的像素
			for (sint32 i = 0; i < height; i++) {
				for (sint32 j = 0; j < width; j++) {
					if (disp_ptr[i * width + j] == Invalid_Float) {
						inv_pixels.emplace_back(i, j);
					}
				}
			}
			trg_pixels = inv_pixels;
		}

		// 遍历待处理像素
        for (auto n = 0u; n < trg_pixels.size(); n++) {
            auto& pix = trg_pixels[n];
            const sint32 y = pix.first;
            const sint32 x = pix.second;

			if (y == height / 2) {
				angle = angle2; 
			}

			// 收集8个方向上遇到的首个有效视差值
			disp_collects.clear();
			for (sint32 s = 0; s < 8; s++) {
				const float32 ang = angle[s];
				const float32 sina = float32(sin(ang));
				const float32 cosa = float32(cos(ang));
				for (sint32 m = 1; ; m++) {
					const sint32 yy = lround(y + m * sina);
					const sint32 xx = lround(x + m * cosa);
					if (yy<0 || yy >= height || xx<0 || xx >= width) {
						break;
					}
					const auto& disp = *(disp_ptr + yy*width + xx);
					if (disp != Invalid_Float) {
						disp_collects.push_back(disp);
						break;
					}
				}
			}
			if(disp_collects.empty()) {
				continue;
			}

			std::sort(disp_collects.begin(), disp_collects.end());

			// 如果是遮挡区，则选择第二小的视差值
			// 如果是误匹配区，则选择中值
			if (k == 0) {
				if (disp_collects.size() > 1) {
					disp_ptr[y*width + x] = disp_collects[1];

				}
				else {
					disp_ptr[y*width + x] = disp_collects[0];
				}
			}
			else{
				disp_ptr[y*width + x] = disp_collects[disp_collects.size() / 2];
			}
		}
	}
}
