function result = PSNR(peak,X,Y)
  result = 10 * log10(peak^2/erreurQuadratiqueMoyenne(X,Y));
end