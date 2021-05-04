# Setting up an SSH tunnel for R Studio server
A tunnel is set up from your laptop. We can do this either through a terminal or using a GUI application, such as Putty (see [how_to_login_ssh.md](how_to_login_ssh.md) for installing Putty). A GUI is handy because we can usually save the session details so next time connecting is a matter of a click or two and we don't have to remember all the IP addresses.

## Terminal
In the example given in the figure, to make the ssh tunnel to the VM we open a terminal application on the laptop and type:
```{bash}
ssh mylogin@128.138.220.251 -L 3000:localhost:8787
```
where `mylogin` is your username on the host. The first part of the command specifies the main SSH connection to the host. The `L` switch indicates "local port forwarding" and specifies that anything we connect to a port on the laptop (i.e. a local port) will be forwarded to a specified IP address and port on the server side. Thus, 3000 is the local port and this will be forwarded to port 8787 on the server's internal network.

You should be prompted for your login credentials to the server.

## GUI SSH application (e.g. Putty)
Open Putty.

On the Connection -> SSH -> Tunnels tab
* Enter Source port: `3000`
* Enter Destination: `localhost:8787` 
* Local and Auto are checked by default
* Click "Add"

The tunnel will be added to the "Forwarded ports" box, which will now list this:
```
L3000 localhost:8787
```

On the "Session" tab, enter the IP address of the server (`128.138.220.251`). You can save the session for later use (e.g. Rstudio_on_melb2).

Now connect to the host: click "Open". You should be prompted for your login credentials to the host. 
