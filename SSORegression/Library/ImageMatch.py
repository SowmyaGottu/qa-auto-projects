import cv2
#from cv2 import cv

def Test_Image_Test():
    method = cv2.TM_SQDIFF_NORMED
    #method = cv2.CV_TM_SQDIFF_NORMED
    #meth = 'CV_TM_SQDIFF_NORMED'
    #method = eval(meth)

    # Read the images from the file
    small_image = cv2.imread('C:\SSO_Regression\Images\CR_Logo.png')
    large_image = cv2.imread('C:\SSO_Regression\Results\selenium-screenshot-2.png')

    result = cv2.matchTemplate(small_image, large_image,method)

    print result

    # We want the minimum squared difference
    mn,_,mnLoc,_ = cv2.minMaxLoc(result)

    print mn,_,mnLoc,_

    # Draw the rectangle:
    # Extract the coordinates of our best match
    MPx,MPy = mnLoc

    # Step 2: Get the size of the template. This is the same size as the match.
    trows,tcols = small_image.shape[:2]

    # Step 3: Draw the rectangle on large_image
    cv2.rectangle(large_image, (MPx,MPy),(MPx+tcols,MPy+trows),(0,0,255),2)

    # Display the original image with the rectangle around the match.
    cv2.imshow('output',large_image)

    # The image is only displayed if we call this
    cv2.waitKey(0)

if __name__ == '__main__':
    Test_Image_Test()