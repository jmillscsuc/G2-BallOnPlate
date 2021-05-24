clear all
close all
clc

coppelia=remApi('remoteApi'); % using the prototype file (remoteApiProto.m)
coppelia.simxFinish(-1); % just in case, close all opened connections
clientID=coppelia.simxStart('127.0.0.1',19999,true,true,5000,5);

if (clientID>-1)
     disp('Connected to remote API server');
     %XCoord = 0.00;
     %YCoord = 0.00;rem
     set_param('Open_loop_Response', 'SimulationCommand', 'start');
     
     %Object handles
     h=[0,0,0];
     %get joint information
        [r,h(1)]=coppelia.simxGetObjectHandle(clientID,'Actuator_X',coppelia.simx_opmode_blocking);
        [r,h(2)]=coppelia.simxGetObjectHandle(clientID,'Actuator_Y',coppelia.simx_opmode_blocking);
        [r,h(3)]=coppelia.simxGetObjectHandle(clientID,'Vision_sensor',coppelia.simx_opmode_blocking);
        
     while true
         %get position of ball
         [r,BallPos]=coppelia.simxGetObjectPosition(clientID,h(3),-1,coppelia.simx_opmode_blocking);
         XCoord=BallPos(1);
         YCoord=BallPos(2);         
       
         %Feed Ball Coordinates to simulink control system.
         set_param('Open_loop_Response/XCoord', 'Value', num2str(XCoord)); %sets value of x-axis input
         pause(0.005) 
         set_param('Open_loop_Response/YCoord', 'Value', num2str(YCoord)); %sets value of y-axis input
         pause(0.005)
         
         %Get new joint target positions from simulink control system output
         OutX=get_param('Open_loop_Response/simoutx', 'RuntimeObject'); %gets 
         NewX=(OutX.InputPort(1).Data *10000);
         OutY=get_param('Open_loop_Response/simouty','RuntimeObject');
         NewY=(OutY.InputPort(1).Data *10000);

         %Set joint target postions with coppeliacoppelia
         coppelia.simxSetJointTargetPosition(clientID,h(1),NewX,coppelia.simx_opmode_streaming); %set position of Xservo
         coppelia.simxSetJointTargetPosition(clientID,h(2),NewY,coppelia.simx_opmode_streaming); %set position of Yservo  
     end 
else
            disp('Failed connecting to remote API server');
end
    coppelia.delete(); 
    disp('Program ended');