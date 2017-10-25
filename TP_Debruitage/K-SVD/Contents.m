%AnalysisKSVDbox - Implementation of analysis K-SVD dictionary learning
%
%  Tomer Peleg
%  Department of Electrical Engineering
%  Technion -- Israel Institute of Technology
%  tomerfa@tx.technion.ac.il
%  Version 1.1 October 2012
%
%  Analysis dictionary learning:
%  AnalysisKSVD - learn an analysis dictionary using a K-SVD-like method.  
%
%  Analysis pursuit:
%  RankBGP  - backward-greedy-pursuit, stop by co-rank.
%  ErrorBGP - backward-greedy-pursuit, stop by residual error.
%
%  Auxiliary functions for analysis pursuit:
%  AddOneElement - add one entry to the co-support, updates the signal 
%                  estimate and the accumulated orthogonal set.
%  ComputeOrthoSet - compute the orthogonal set for the rows of a matrix
%
%  Auxiliary functions related to the analysis dictionary:   
%  GenerateRandomRow - generate one analysis atom from a given data set 
%                      of signals, by drawing at random d-1 signals and 
%                      computing the vector that spans their nullspace.
%  DisplayOmega - display the analysis dictionary.
%  normrows - normalize the rows of a matrix.
%  normcols - normalize the columns of a matrix.
%  multrows - multiplie the rows of a matrix by scalar values.
%  multcols - multiplie the column of a matrix by scalar values.
%  dictdist - compute the distance between two dictionaries.
%
%  Auxiliary functions for synthetic tests:
%  GenerateOmegaDIF - generate the Omega_DIF analysis dictionary. 
%  GenerateAnalysisSignals - generate analysis signals lying in 
%                            r-dimensional nullspaces corresponding to a
%                            given analysis dictionary.
%
%  Auxiliary functions for patch-based image denoising:
%  im2colstep - rearrange matrix blocks into columns.
%  col2imstep - rearrange matrix columns into blocks.
%  countcover - covering of signal samples by blocks 
%
%  Demonstrations:
%  TestPursuitOmegaDIF   - synthetic tests of the analysis pursuit methods 
%                          for Omega_DIF. 
%  TestKSVDRandomOmega   - synthetic tests of the analysis K-SVD algorithm 
%                          for a random Omega. 
%  TestKSVDOmegaDIF      - synthetic tests of the analysis K-SVD algorithm 
%                          for Omega_DIF. 
%  TestKSVDPWCImage      - learn analysis dictionary from noisy piece-wise 
%                          constant image patches, and tests patch-based 
%                          image denoising with the learned dictionary.
%  TestKSVDNaturalImages - learn analysis dictionary from noisy natural 
%                          image patches, and tests patch-based image 
%                          denoising with the learned dictionary.
%
%  References:
%  [1] R. Rubinstein, T. Peleg, and M. Elad, "Analysis K-SVD: a 
%      dictionary-learning algorithm for the Analysis Sparse Model", 
%      to appear in IEEE Trans. Signal Processing.
%  [2] R. Rubinstein, T. Peleg, and M. Elad, "K-SVD dictionary-learning 
%      for the analysis sparse model", in ICASSP, Kyoto, Japan, March 2012.
%