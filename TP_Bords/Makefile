CC = g++

.SUFFIXES: .cc .h
  
CPPFLAGS = `pkg-config --cflags opencv` -s -DMAIN -I/usr/include -Wall
ENDFLAGS = `pkg-config --libs opencv` -L/usr/X11R6/lib   -lXt -lX11 -lm
INCLUDE  = /usr/local/include/opencv


.cc:
	${CC} -I${INCLUDE} ${CPPFLAGS} -o $@ $< ${ENDFLAGS}

