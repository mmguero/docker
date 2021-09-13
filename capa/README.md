# capa, dockerized

A simple Docker container for [fireeye/capa](https://github.com/fireeye/capa). This includes a [capa-docker.sh](capa-docker.sh) bash wrapper script which copies the PE file to be analyzed to a temporary directory, bind mounts that directory to the container and runs `capa` on it.

## Usage

```
capa-docker.sh <IN_FILE> [capa options]
```

## Example

```
user@host tmp › capa-docker.sh example.exe
usermod: no changes
capa
uid=1000(capa) gid=1000(capa) groups=1000(capa)
loading : 100%|###########################################################| 485/485 [00:00<00:00, 1237.93 rules/s]
matching: 100%|###########################################################| 637/637 [00:53<00:00, 11.91 functions/s]
+------------------------+------------------------------------------------------------------------------------+
| md5                    | 73633c847fe3699f9e4ab0bf9d27ce83                                                   |
| sha1                   | fc7385f655a414ca91198f7ed3cb882e234095f4                                           |
| sha256                 | 612fa0325340f226d623ec6b967f5a40aef1761ac066bb884290edf99d9c941a                   |
| path                   | /data/example.exe                                                                  |
+------------------------+------------------------------------------------------------------------------------+

+------------------------+------------------------------------------------------------------------------------+
| ATT&CK Tactic          | ATT&CK Technique                                                                   |
|------------------------+------------------------------------------------------------------------------------|
| DEFENSE EVASION        | Hide Artifacts::Hidden Window [T1564.003]                                          |
|                        | Obfuscated Files or Information [T1027]                                            |
|                        | Virtualization/Sandbox Evasion::System Checks [T1497.001]                          |
| DISCOVERY              | File and Directory Discovery [T1083]                                               |
|                        | Query Registry [T1012]                                                             |
|                        | System Information Discovery [T1082]                                               |
| EXECUTION              | Command and Scripting Interpreter [T1059]                                          |
|                        | Shared Modules [T1129]                                                             |
|                        | System Services::Service Execution [T1569.002]                                     |
+------------------------+------------------------------------------------------------------------------------+

+-----------------------------+-------------------------------------------------------------------------------+
| MBC Objective               | MBC Behavior                                                                  |
|-----------------------------+-------------------------------------------------------------------------------|
| ANTI-BEHAVIORAL ANALYSIS    | Virtual Machine Detection::Instruction Testing [B0009.029]                    |
| CRYPTOGRAPHY                | Encrypt Data::RC4 [C0027.009]                                                 |
|                             | Generate Pseudo-random Sequence::RC4 PRGA [C0021.004]                         |
| DATA                        | Checksum::CRC32 [C0032.001]                                                   |
|                             | Encoding::XOR [C0026.002]                                                     |
| DEFENSE EVASION             | Obfuscated Files or Information::Encoding-Standard Algorithm [E1027.m02]      |
| FILE SYSTEM                 | Get File Attributes [C0049]                                                   |
|                             | Read File [C0051]                                                             |
|                             | Write File [C0052]                                                            |
| OPERATING SYSTEM            | Registry::Create Registry Key [C0036.004]                                     |
|                             | Registry::Open Registry Key [C0036.003]                                       |
|                             | Registry::Query Registry Value [C0036.006]                                    |
| PROCESS                     | Allocate Thread Local Storage [C0040]                                         |
|                             | Create Thread [C0038]                                                         |
|                             | Set Thread Local Storage Value [C0041]                                        |
|                             | Terminate Process [C0018]                                                     |
+-----------------------------+-------------------------------------------------------------------------------+

+------------------------------------------------------+------------------------------------------------------+
| CAPABILITY                                           | NAMESPACE                                            |
|------------------------------------------------------+------------------------------------------------------|
| execute anti-VM instructions                         | anti-analysis/anti-vm/vm-detection                   |
| hash data with CRC32 (2 matches)                     | data-manipulation/checksum/crc32                     |
| encode data using XOR (13 matches)                   | data-manipulation/encoding/xor                       |
| encrypt data using RC4 PRGA (2 matches)              | data-manipulation/encryption/rc4                     |
| contains PDB path                                    | executable/pe/pdb                                    |
| contain a resource (.rsrc) section                   | executable/pe/section/rsrc                           |
| accept command line arguments                        | host-interaction/cli                                 |
| interact with driver via control codes (8 matches)   | host-interaction/driver                              |
| query environment variable                           | host-interaction/environment-variable                |
| get common file path                                 | host-interaction/file-system                         |
| get file attributes                                  | host-interaction/file-system/meta                    |
| get file version info                                | host-interaction/file-system/meta                    |
| read .ini file (4 matches)                           | host-interaction/file-system/read                    |
| read file (7 matches)                                | host-interaction/file-system/read                    |
| write file (13 matches)                              | host-interaction/file-system/write                   |
| hide graphical window (2 matches)                    | host-interaction/gui/window/hide                     |
| enumerate disk volumes                               | host-interaction/hardware/storage                    |
| get disk information (7 matches)                     | host-interaction/hardware/storage                    |
| get disk size                                        | host-interaction/hardware/storage                    |
| print debug messages                                 | host-interaction/log/debug/write-event               |
| get system information                               | host-interaction/os/info                             |
| check OS version                                     | host-interaction/os/version                          |
| allocate thread local storage                        | host-interaction/process                             |
| get thread local storage value                       | host-interaction/process                             |
| read process memory                                  | host-interaction/process                             |
| set thread local storage value                       | host-interaction/process                             |
| terminate process (2 matches)                        | host-interaction/process/terminate                   |
| terminate process via fastfail (4 matches)           | host-interaction/process/terminate                   |
| query or enumerate registry value                    | host-interaction/registry                            |
| create thread (3 matches)                            | host-interaction/thread/create                       |
| link function at runtime (12 matches)                | linking/runtime-linking                              |
| link many functions at runtime                       | linking/runtime-linking                              |
| parse PE exports                                     | load-code/pe                                         |
| parse PE header (5 matches)                          | load-code/pe                                         |
+------------------------------------------------------+------------------------------------------------------+
```