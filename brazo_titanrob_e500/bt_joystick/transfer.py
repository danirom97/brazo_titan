#!/usr/bin/env python
import rospy
from geometry_msgs.msg import PoseStamped
from std_msgs.msg import Float64
from std_msgs.msg import String


def talker(posx,posy,posx2,posy2,v):
    pub1 = rospy.Publisher('/bt/joint1_controller/command', Float64, queue_size=1)
    pub2 = rospy.Publisher('/bt/joint2_controller/command', Float64, queue_size=1)
    pub3 = rospy.Publisher('/bt/joint3_controller/command', Float64, queue_size=1)
    pub4 = rospy.Publisher('/bt/joint4_controller/command', Float64, queue_size=1)
    pub5 = rospy.Publisher('/bt/joint_pext_controller/command', Float64, queue_size=1)
    pub6 = rospy.Publisher('/bt/joint_pint_controller/command', Float64, queue_size=1)
    rate = rospy.Rate(100) # 50hz

    

    pub1.publish(posx)
    pub2.publish(posy)
    pub3.publish(posy2)
    pub4.publish(posx2)
    pub5.publish(v*1.025)
    pub6.publish(v)
    rate.sleep()

def callback1(data):
    x = data.pose.position.x/35 * -0.15
    y = data.pose.position.y/35 * 0.15
    rospy.loginfo(rospy.get_caller_id() + "  I heard %f", x)

    try:
       talker(x,y,0,0,0)
    except rospy.ROSInterruptException:
        pass

def callback2(data):
    x = data.pose.position.x/49.5 * 3.86
    y = data.pose.position.y/49.5 * 0.15
    rospy.loginfo(rospy.get_caller_id() + "  I heard %f", x)

    try:
       talker(0,0,x,y,0)
    except rospy.ROSInterruptException:
        pass

def callback3(msg):

    rospy.loginfo(msg.data)

    v = float(msg.data) * 0.39
    rospy.loginfo(v)

    try:
       talker(0,0,0,0,v)
    except rospy.ROSInterruptException:
        pass
        
def listener():

    # In ROS, nodes are uniquely named. If two nodes with the same
    # name are launched, the previous one is kicked off. The
    # anonymous=True flag means that rospy will choose a unique
    # name for our 'listener' node so that multiple listeners can
    # run simultaneously.
    rospy.init_node('listener', anonymous=True)
    i = 1

    rospy.Subscriber("/joy_pose_1", PoseStamped, callback1)
    rospy.Subscriber("/joy_pose_2", PoseStamped, callback2)
    rospy.Subscriber("/joy_pose_grip", String, callback3)

    # spin() simply keeps python from exiting until this node is stopped
    rospy.spin()

if __name__ == '__main__':
    listener()
