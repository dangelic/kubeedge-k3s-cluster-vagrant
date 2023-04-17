Ref: https://github.com/haicgu/training/blob/main/Cloud-Edge/KubeEdge/kubeedge-counter-demo.md

### KubeEdge DeviceTwin Demo: Counter App
NOTE: This setup is adjusted for containerd as it is used as CRI for the Edge Nodes.

## 1. Deploy Mapper
NOTE: If more than 1 Edge Node is running, make sure that the values map!
```
sed -i "s#kubeedge/#mayday/#" kubeedge-pi-counter-app.yaml
sudo kubectl create -f kubeedge-pi-counter-app.yaml
sudo kubectl get pod -owide |grep counter
```

## 2. Create Device Model

```
sudo kubectl create -f kubeedge-counter-model.yaml
sudo kubectl get devicemodel counter-model
```

## 3. Create the Device Instance of the Device Model

```
# Replace with Edge Node name.
sed -i "s#edge-node#<your edge node name>#" kubeedge-counter-instance.yaml
sudo kubectl create -f kubeedge-counter-instance.yaml
sudo kubectl get device counter -ojson
```

## 4. At Edge: Get Counter Logs

NOTE: Nothing should appear as the counter is off...
```
crictl ps
crictl logs -f <the process name>
```

## 5. Turn the device on from the Cloud
Change Value from "OFF" to "ON"
```
sudo nano kubeedge-counter-instance.yaml
sudo kubectl apply -f kubeedge-counter-instance.yaml
```

## 6. Check Device Status remote from the Cloud
NOTE: Check the status the pseudo Edge Device pings
```
sudo kubectl get device counter -ojson
```

### 7. At Edge: Get Counter logs again
NOTE: The device has a heartbeat now!
```
crictl ps
crictl logs -f <the process name>
```