%Group 2, Spring 2021
%Ball and Plate Project
%standard command window/workspace clearing
clear all
close all
clc


coppelia=remApi('remoteApi');
coppelia.simxFinish(-1); %  close all previously opened connections
clientID=coppelia.simxStart('127.0.0.1',19999,true,true,5000,5); %connecing CoppeliaSim and Matlab

if (clientID>-1) %executes if connection is successful
     disp('Connected to remote API server'); %declares successful connection in command window
     set_param('Open_loop_Response', 'SimulationCommand', 'start'); %connecting Simulink Block Diagram as the Controller for the CoppeliaSim Simulation
     
     %CoppeliaSim Object handles (Servos and Ball)
     h=[0,0,0];
     %get joint information
        [r,h(1)]=coppelia.simxGetObjectHandle(clientID,'Actuator_X',coppelia.simx_opmode_blocking); %sets X-axis Servo handle to h(1)
        [r,h(2)]=coppelia.simxGetObjectHandle(clientID,'Actuator_Y',coppelia.simx_opmode_blocking); %sets Y-axis Servo handle to h(2)
        [r,h(3)]=coppelia.simxGetObjectHandle(clientID,'Vision_sensor',coppelia.simx_opmode_blocking); %sets Ball Position handle to h(3)
        
     while true
         %get position of ball
         [r,BallPos]=coppelia.simxGetObjectPosition(clientID,h(3),-1,coppelia.simx_opmode_blocking); %loads 2 col vector of ball into variable Ballpos
         XCoord=BallPos(1); 
         YCoord=BallPos(2);         
       
         %Input Ball Position to Simulink control system.
         set_param('Open_loop_Response/XCoord', 'Value', num2str(XCoord)); %sets value of x-axis input
         pause(0.005) 
         set_param('Open_loop_Response/YCoord', 'Value', num2str(XCoord)); %sets value of y-axis input
         pause(0.005)
         
         %Get joint target positions from Simulink control system output
         OutX=get_param('Open_loop_Response/XAngle', 'RuntimeObject'); %gets x-axis servo position
         NewX=(OutX.OutputPort(1).Data *10000);
         OutY=get_param('Open_loop_Response/YAngle','RuntimeObject'); %gets x-axis servo position
         NewY=(OutY.OutputPort(1).Data *10000);

         %Set joint target postions in CoppeliaSim
         coppelia.simxSetJointTargetPosition(clientID,h(1),NewX,coppelia.simx_opmode_streaming); %set position of Xservo
         coppelia.simxSetJointTargetPosition(clientID,h(2),NewY,coppelia.simx_opmode_streaming); %set position of Yservo  
     end 
else
            disp('Failed connecting to remote API server');
end
    coppelia.delete(); 
    disp('Program ended');