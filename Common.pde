int mousePressPosX, mousePressPosY;
boolean setMousePressPos = false;
int mouseScroll;

void mousePressed(){
  if (!setMousePressPos) {
    mousePressPosX = mouseX;
    mousePressPosY = mouseY;
    setMousePressPos = true;
  }
  
}
void mouseReleased(){
  setMousePressPos = false;
}

void mouseWheel(MouseEvent event){
  mouseScroll = event.getCount();
}
