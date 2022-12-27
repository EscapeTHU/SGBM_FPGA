import numpy as np
import cv2
import matplotlib.pyplot as plt

left_img = cv2.imread("./Data/new_ZED2/left.png", -1)
right_img = cv2.imread("./Data/new_ZED2/right.png", -1)
stereo = cv2.StereoSGBM_create(minDisparity = 1, numDisparities = 256)
disparity = stereo.compute(left_img, right_img)
plt.imshow(disparity)
plt.show()
np.savetxt("./Data/new_ZED2/opencv.txt", disparity, delimiter='\t')
print("saved...")
