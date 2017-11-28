// Programme source exemple pour le TP d'Analyse d'<images
// Université de Toulouse 3 - Paul Sabatier © 2017
//
// à compiler avec le Makefile fourni : make TP_exemple

#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/highgui/highgui.hpp"
#include <iostream>
#include <iomanip>

using namespace cv;

// binarise() ----------------------------------------------------------//
// binarise l'image en niveaux de gris X selon le paramètre seuil	//
// et renvoie le résultat dans Y.					//
//----------------------------------------------------------------------//

int main (int argc, char** argv)
{
  cv::Mat src, dstx, dsty, kernel;  
  
  cv::Point anchor = cv::Point( -1, -1 );
  float delta = 0;
  int ddepth = -1;

  int threshold_type = 0;
  int const max_BINARY_value = 255;

  src=cv::imread(argv[1], CV_LOAD_IMAGE_COLOR);  

  kernel = (cv::Mat_<double>(3,3) << 1, 2, 1, 0, 0, 0, -1, -2, -1);

  cv::filter2D(src, dsty, ddepth , kernel, anchor, delta, cv::BORDER_DEFAULT );

  kernel = (cv::Mat_<double>(3,3) << 1, 0, -1, 2, 0, -2, 1, 0, -1);

  cv::filter2D(src, dstx, ddepth , kernel, anchor, delta, cv::BORDER_DEFAULT );

  //Seuillage simple
  cv::Mat temp = cv::abs(dstx) + cv::abs(dsty);
  double min, max;
  cv::minMaxLoc(temp, &min, &max);

  cv::imshow( "Affiche_sobel", temp);

  cv::Mat result;
  threshold( temp, result, ( min + max ) / 2, max_BINARY_value, threshold_type );

  cv::imshow( "Affiche_origine", src);

  cv::imshow( "Affiche_seuille", result);

  //Suivi de crête



  cvWaitKey();	
  exit (0);
}
