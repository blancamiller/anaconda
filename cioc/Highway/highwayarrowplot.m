% Plot the shape of an arrow in front of a car.
function [xv,yv] = highwayarrowplot(pos,theta,car_width,car_height)

xv = [pos(1) - car_width*0.4*cos(theta) + car_height*1.2*sin(theta),...
      pos(1) - car_width*0.4*cos(theta) + car_height*1.8*sin(theta),...
      pos(1) - car_width*0.7*cos(theta) + car_height*1.8*sin(theta),...
      pos(1) + car_height*2.2*sin(theta),...
      pos(1) + car_width*0.7*cos(theta) + car_height*1.8*sin(theta),...
      pos(1) + car_width*0.4*cos(theta) + car_height*1.8*sin(theta),...
      pos(1) + car_width*0.4*cos(theta) + car_height*1.2*sin(theta),...
      pos(1) - car_width*0.4*cos(theta) + car_height*1.2*sin(theta),...
      pos(1) - car_width*0.4*cos(theta) + car_height*1.8*sin(theta)];
yv = [pos(2) + car_width*0.4*sin(theta) + car_height*1.2*cos(theta),...
      pos(2) + car_width*0.4*sin(theta) + car_height*1.8*cos(theta),...
      pos(2) + car_width*0.7*sin(theta) + car_height*1.8*cos(theta),...
      pos(2) + car_height*2.2*cos(theta),...
      pos(2) - car_width*0.7*sin(theta) + car_height*1.8*cos(theta),...
      pos(2) - car_width*0.4*sin(theta) + car_height*1.8*cos(theta),...
      pos(2) - car_width*0.4*sin(theta) + car_height*1.2*cos(theta),...
      pos(2) + car_width*0.4*sin(theta) + car_height*1.2*cos(theta),...
      pos(2) + car_width*0.4*sin(theta) + car_height*1.8*cos(theta)];
