# How to run R using R studio server
[R Studio server](https://support.rstudio.com/hc/en-us/articles/234653607-Getting-Started-with-RStudio-Server) allows you to run the R Studio GUI from within a web browser. It's the quickest and most convenient way to interact with our server.

First [establish an SSH tunnel session](how_to_tunnel_ssh.md) using either the command line or Putty.

Once the tunnel is set up, you need to leave the SSH session open to access the tunnel from your web browser. Open your web browser (e.g. Firefox) and type in the following address (the "entrance" to the tunnel):

http://localhost:3000

You should be asked for your username and password and then you'll be in an R Studio session in the browser. 

It's handy to use the SSH command line session or a separate SSH session to manage and transfer files. See [how_to_transfer_files.md](how_to_transfer_files.md).

Don't forget to logout of the browser session when you are done or are taking a break! If you don't log out, you've left the door to the server open and accessible from your browser - and it seems to persist indefinitely.

**Limitations:** This solution will be slow for dense graphs (i.e. large datasets) since all the datapoints in a graph need to be transferred from server to client. You can't break out a code panel into a separate window and use multiple monitors, although you can stretch your browser window across two monitors.

