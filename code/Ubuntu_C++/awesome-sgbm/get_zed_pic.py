import pyzed.sl as sl
import cv2
import numpy as np

def get_pic():
    zed = sl.Camera()
    init = sl.InitParameters()
    init.depth_mode = sl.DEPTH_MODE.PERFORMANCE
    init.coordinate_units = sl.UNIT.METER
    init.camera_resolution = sl.RESOLUTION.HD720
    init.camera_fps = 30
    
    err = zed.open(init)
    
    if err != sl.ERROR_CODE.SUCCESS:
        print("ZED Camera opened abnormally! Aborting this thread...")
        exit(1)
    
    run_p = sl.RuntimeParameters()
    run_p.sensing_mode = sl.SENSING_MODE.STANDARD
    run_p.confidence_threshold = 100
    run_p.textureness_confidence_threshold = 100
    
    image_left = sl.Mat()
    image_right = sl.Mat()
    depth = sl.Mat()
    ptcld = sl.Mat()
    
    mirror_ref = sl.Transform()
    mirror_ref.set_translation(sl.Translation(2.75, 4.0, 0))
    tr_np = mirror_ref.m
    
    while True:
        if zed.grab(run_p) == sl.ERROR_CODE.SUCCESS:
            zed.retrieve_image(image_left, sl.VIEW.LEFT)
            zed.retrieve_image(image_right, sl.VIEW.RIGHT)
            zed.retrieve_measure(depth, sl.MEASURE.DEPTH)
            
            left_pic = image_left.get_data()
            right_pic = image_right.get_data()
            depth_pic = depth.get_data()
            
            cv2.imshow("zed2 left", left_pic[:,:,:3])
            cv2.imshow("zed2 right", right_pic[:,:,:3])
            cv2.imshow("zed2 depth", depth_pic)
            
            new_dpt = depth_pic.copy()
            new_dpt[np.isnan(new_dpt)] = 0
            new_dpt[np.isinf(new_dpt)] = 0
            print(np.max(new_dpt))
            aa = cv2.waitKey(1)
            if aa == ord('q'):
                break
            if aa == ord('s'):
                cv2.imwrite('./Data/test/left.png', left_pic[:,:,:3])
                cv2.imwrite('./Data/test/right.png', right_pic[:,:,:3])
                # cv2.imwrite('./Data/ZED2/depth.png', depth_pic)
                np.savetxt('./Data/test/depth.txt', depth_pic, delimiter = '\t')

get_pic()
