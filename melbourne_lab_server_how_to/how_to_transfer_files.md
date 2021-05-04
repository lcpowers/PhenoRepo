# Transfer files to/from the server
How to transfer files between your laptop/desktop (client) and the server.

The ssh daemon on the linux server runs an SFTP server. This means that file transfers are done over the ssh connection.


## GUI applications for client
A GUI application is much faster and more convenient than the command line.
* [WinSCP](http://winscp.net) (opensource). Win (recommended).
* [Cyberduck](https://cyberduck.io/) (opensource). Win, Mac (recommended).
* [Filezilla](https://filezilla-project.org/) (opensource). Win, Mac, Linux.

In WinSCP and Filezilla the file browser has two window panes, one showing files on the client, the other showing files on the server. You can manually transfer files back and forth or set it to synchronize client and host. Cyberduck presents a browser for the server's file system and you can drag and drop files to/from there, or set it to synchronize a folder.


## Desktop Linux client
Most desktop linux file browsers have SFTP built in. Precede the location address with `sftp:\\`.


## Command line
Command line tools work in Windows 10 (using Windows Subsystem for Linux), Mac, or Linux clients. I believe SFTP is the most modern protocol, so use the `sftp` tool. The `scp` command can also be used but it apparently uses an older version of SSH, so `sftp` is preferred. The command line is a hassle for routine and frequent file transfers, such as during an analysis session. It can be a good approach for transfers of large files from cloud services such as Amazon Web Services.

