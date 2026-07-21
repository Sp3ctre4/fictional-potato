import sys

if sys.platform.startswith("linux"):
    from opencanary.modules import CanaryService, FileSystemWatcher
    import re

    class SambaLogWatcher(FileSystemWatcher):
        def __init__(self, logFile=None, logger=None):
            self.logger = logger
            FileSystemWatcher.__init__(self, fileName=logFile)

        def handleLines(self, lines=None):
            audit_re = re.compile(r"^.*smbd_audit.*: (.*$)")

            for line in lines:
                matches = audit_re.match(line)

                # Skip lines that do not match the correct RegEx pattern
                if matches is None:
                    continue

                data = matches.groups()[0].split("|")

                        # %I    client IP
                        # %i    local IP
                        # %U	session username
                        # %M    Internet name of client machine
                        # %L    NetBIOS name of the server
                        # %T    current date and time

                srcHost = data[0]
                dstHost = data[1]
                user = data[2]
                srcHostName = data[3]
                dstHostName = data[4]
                # 5 is time
                auditAction = data[6]
                # 7 is status
                # 8 is attribute
                # 9 + 10 define action
                userAction = data[9] + " " + data[10]
                path = data[11]

                if user == "":
                    user = "anonymous"

                if dstHostName == "":
                    dstHostName = "Non-Interactive Session"

                data = {}
                data["src_host"] = srcHost
                data["src_port"] = "-1"
                data["dst_host"] = dstHost
                data["dst_port"] = 445
                data["logtype"] = self.logger.LOG_SMB_FILE_OPEN
                data["logdata"] = {
                    "USER": user,
                    "REMOTENAME": srcHostName,
                    "LOCALNAME": dstHostName,
                    "AUDITACTION": auditAction,
                    "ACTION": userAction,
                    "FILENAME": path,
                }
                self.logger.log(data)

    class CanarySamba(CanaryService):
        NAME = "smb"

        def __init__(self, config=None, logger=None):
            CanaryService.__init__(self, config=config, logger=logger)
            self.audit_file = config.getVal(
                "smb.auditfile", default="/var/log/samba-audit.log"
            )
            self.config = config

        def startYourEngines(self, reactor=None):
            # create samba run dir, so testparm doesn't error
            # try:
            #    os.stat('/var/run/samba')
            # except OSError:
            #    os.mkdir('/var/run/samba')

            fs = SambaLogWatcher(logFile=self.audit_file, logger=self.logger)
            fs.start()
