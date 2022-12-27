import matplotlib.pyplot as plt
from mpl_toolkits import mplot3d
import cv2
import numpy as np
import open3d as o3d

cx = 972.9
cy = 565.322
fx = 1058.5601
fy = 1057.7600

disparity = np.loadtxt('./Data/FPGA_proc/disparity.txt', delimiter = '\t')
new_disp = np.zeros(disparity.shape)
for i in range(disparity.shape[0]):
    for j in range(disparity.shape[1]):
        if disparity[i,j] < 30 or disparity[i,j] > 60:
            continue
        else:
            new_disp[i,j] = fx*0.12/disparity[i,j]
disparity = new_disp
# depth = cv2.imread('./Data/test/depth.png', -1)/2**16*100
depth = cv2.imread('./Data/final_test/depth.png', -1)*0.001

left = cv2.imread("./Data/final_test/left.png", -1)

gridyy, gridxx = np.mgrid[:depth.shape[0], :depth.shape[1]]
xx_sgbm = (gridxx-cx)/fx*disparity
yy_sgbm = (gridyy-cy)/fy*disparity
zz_sgbm = disparity[..., np.newaxis]

print(xx_sgbm.shape)
print(yy_sgbm.shape)
print(zz_sgbm.shape)
xyz_sgbm = np.concatenate([xx_sgbm[..., np.newaxis], yy_sgbm[..., np.newaxis], zz_sgbm], axis = 2)
#xyz_sgbm = xyz_sgbm[xyz_sgbm[:,:,2]>1]
xyz_sgbm = np.reshape(xyz_sgbm, (-1, 3))

xx_zed2 = (gridxx-cx)/fx*depth
yy_zed2 = (gridyy-cy)/fy*depth
zz_zed2 = depth[..., np.newaxis]
xyz_zed2 = np.concatenate([xx_zed2[..., np.newaxis], yy_zed2[..., np.newaxis], zz_zed2], axis = 2)
#xyz_zed2 = xyz_zed2[xyz_zed2[:,:,2]>1]
xyz_zed2 = np.reshape(xyz_zed2, (-1, 3))


left_c = np.reshape(left, (-1,3))/255.0

pcd_sgbm = o3d.geometry.PointCloud()
pcd_sgbm.points = o3d.utility.Vector3dVector(xyz_sgbm)
pcd_sgbm.colors = o3d.utility.Vector3dVector(left_c)
pcd_zed2 = o3d.geometry.PointCloud()
pcd_zed2.points = o3d.utility.Vector3dVector(xyz_zed2)
# pcd_zed2.colors = o3d.utility.Vector3dVector(left_c)
# o3d.visualization.draw_geometries([pcd_sgbm])
# o3d.visualization.draw_geometries([pcd_zed2])
o3d.visualization.draw_geometries([pcd_zed2, pcd_sgbm])

"""
fig = plt.figure()
ax = mplot3d.Axes3D(fig)
ax.scatter3D(xyz_sgbm.T[0], xyz_sgbm.T[1], xyz_sgbm.T[2], c = 'r')
ax.scatter3D(xyz_zed2.T[0], xyz_zed2.T[1], xyz_zed2.T[2], c = 'y')
plt.show()
"""
