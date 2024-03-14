import os
import shutil

script_path = os.path.dirname(os.path.abspath(__file__))

number_of_znodes=3

for i in range(1,number_of_znodes+1):
    os.mkdir(os.path.join(script_path,f"zookeeper{i}"))
    os.mkdir(os.path.join(script_path,f"zookeeper{i}/data"))
    
    shutil.copyfile(
        os.path.join(script_path,"zoo.cfg"),
        os.path.join(script_path,f"zookeeper{i}/zoo.cfg")
    )

    with open(
        os.path.join(script_path,f"zookeeper{i}/data/myid")
        ,"w"
    ) as fp:
        fp.write(f"{i}")