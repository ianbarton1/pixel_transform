//User configurable settings
//note that multi-threading improves performance but is not guaranteed to be 100% accurate
int thread_count = 1;
//image_size improves performance by downscaling images. Images should be 1:1 aspect ratio
int img_size = 256;
//set which files you want to use
//file_1 is the 'source', file_2 is the 'target'
//both should be in the data directory
String file_1 = "image1.jpg";
String file_2 = "image2.jpg";


PImage src_image;
PImage tar_image;
PImage trans_image;
IntList pallette_r = new IntList();
IntList pallette_g = new IntList();
IntList pallette_b = new IntList();
IntList pallette_used = new IntList();
IntList trans_order = new IntList();
int i;
int thread_spawn = 0;
int s_size;


void setup(){
  size(1536,512);
  src_image = loadImage(file_1);
  tar_image = loadImage(file_2);
  src_image.resize(img_size,img_size);
  tar_image.resize(img_size,img_size);
  trans_image = createImage(img_size,img_size,0);
  src_image.loadPixels();
  tar_image.loadPixels();
  trans_image.loadPixels();
  s_size = src_image.width * src_image.height;
  for (int i = 0; i < s_size; i++) {
   pallette_r.append(int(red(src_image.pixels[i]))); 
   pallette_g.append(int(green(src_image.pixels[i]))); 
   pallette_b.append(int(blue(src_image.pixels[i])));
   pallette_used.append(0);
   trans_order.append(i);
  }
  trans_order.shuffle();

for (int i=0; i< thread_count; i++) {
thread("new_thread");
}
}
void new_thread() {
  thread_spawn++;
  int thread_id = thread_spawn;
 Pixel_transform((s_size/thread_count * (thread_spawn-1)), (s_size/thread_count * thread_spawn)); 
 println("Thread "+thread_id+" done");
}

void Pixel_transform(int i_start, int i_stop) {
int t_size = tar_image.width * tar_image.height;
float col_err;
float dist;
int col_index;
int i;
for (int i_2 = i_start;i_2 < i_stop; i_2++) {
    i = trans_order.get(i_2);
    //i = i_2;
    dist = 0;
    col_index = 0;
    col_err = 200000;
    for(int j = 0; j < pallette_r.size(); j++) {
      if (pallette_used.get(j) == 0) {
       dist = pow(pallette_r.get(j) - red(tar_image.pixels[i]),2);
       if (dist < col_err) dist += pow(pallette_g.get(j) -  green(tar_image.pixels[i]),2);
       if (dist < col_err) dist += pow(pallette_b.get(j) -  blue(tar_image.pixels[i]),2);
       if (dist < col_err) {
       col_err = dist;
       col_index = j; 
       }
      }
    }
    
       trans_image.pixels[i] =
       color(pallette_r.get(col_index),
       pallette_g.get(col_index),
       pallette_b.get(col_index));
       //pallette_r.remove(col_index);
       //pallette_g.remove(col_index);
       //pallette_b.remove(col_index);
       pallette_used.set(col_index,1);
       trans_image.updatePixels();
}
}



void draw() {
  scale(512/img_size);
  image(src_image, 0,0);
  image(tar_image, img_size,0);
  image(trans_image, img_size*2,0);
}
