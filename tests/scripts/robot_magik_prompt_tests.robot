*** Settings ***
Documentation     Test Parsing different Magik Prompt Variations.
...
...               - SW GIS 4.x and corresponding remote_cli uses as prompt *MagikSF>*
...               - SW GIS 5.0 uses as prompt *Magik>*, corresponding remote_cli still uses as prompt *MagikSF>*
...               - future SW GIS 5.x should use as prompt *Magik>* also for the corresponding remote_cli
...
...               This test suite uses the script _dummy_remte_cli.py_ to simulate a remote_cli with different prompt variations and prepared return values.
...               == Licence info ==
...               | Copyright 2019-2023 Luiko Czub, Smallcases Software GmbH
...               |
...               | Licensed under the Apache License, Version 2.0 (the "License");
...               | you may not use this file except in compliance with the License.
...               | You may obtain a copy of the License at
...               |
...               | http://www.apache.org/licenses/LICENSE-2.0
...               |
...               | Unless required by applicable law or agreed to in writing, software
...               | distributed under the License is distributed on an "AS IS" BASIS,
...               | WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
...               | See the License for the specific language governing permissions and
...               | limitations under the License.
Test Tags        PromptTest
Library           Process
Resource          ../../resources/robot_magik_base.robot

*** Variables ***
${DUMMY_CLI_PORT}    14011
${DUMMY_CLI_SCRIPT}    ${CURDIR}${/}dummy_remote_cli.py
${CLI_PORT}       ${DUMMY_CLI_PORT}

*** Test Cases ***
Test Open Magik Connection - MagikSF>
    ${prompt}=    Set Variable    MagikSF
    ${out}=    Open Magik Connection with special prompt    ${prompt}
    Should Match Regexp    ${out}    \\S+:\\d+:${prompt}>
    [Teardown]    Stop Dummy Remote Cli

Test Open Magik Connection - Magik>
    ${prompt}=    Set Variable    Magik
    ${out}=    Open Magik Connection with special prompt    ${prompt}
    Should Match Regexp    ${out}    \\S+:\\d+:${prompt}>
    [Teardown]    Stop Dummy Remote Cli

Test Read Magik Output - MagikSF>
    Open Magik Connection with special prompt    MagikSF
    Write Bare    write("1 ernie", %newline, "2 bert", %newline, "3 bibo")\n$\n
    ${out}=    Read Magik Output
    Should Match Regexp    ${out}    ^1 ernie\\s2 bert\\s3 bibo$
    Write Bare    \n$\n
    ${out}=    Read Magik Output
    Write Bare    1.as_error()\n$\n
    Run Keyword And Expect Error    *traceback*    Read Magik Output
    [Teardown]    Stop Dummy Remote Cli

Test Read Magik Output - Magik>
    Open Magik Connection with special prompt    Magik
    Write Bare    write("1 ernie", %newline, "2 bert", %newline, "3 bibo")\n$\n
    ${out}=    Read Magik Output
    Should Match Regexp    ${out}    ^1 ernie\\s2 bert\\s3 bibo$
    Write Bare    \n$\n
    ${out}=    Read Magik Output
    Write Bare    1.as_error()\n$\n
    Run Keyword And Expect Error    *traceback*    Read Magik Output
    [Teardown]    Stop Dummy Remote Cli

*** Keywords ***
Start Dummy Remote Cli
    [Arguments]    ${prompt}=MagikSF    ${cli_port}=${DUMMY_CLI_PORT}    ${max_connections}=1
    [Documentation]    Starts a telnet server process, simulating a SW GIS remote_cli with a special prompt.
    ...
    ...    Telnet server process will be started using process libary keyword _Start Process_ , running in the background.
    ${handle_cli}=    Process.Start Process    python    ${DUMMY_CLI_SCRIPT}    ${cli_port}    ${max_connections}    ${prompt}
    ...    alias=dummy_cli
    RETURN    ${handle_cli}

Stop Dummy Remote Cli
    [Arguments]    ${prompt}=MagikSF
    [Documentation]    Stops the running telnet server process, which simulating a SW GIS remote_cli with a special prompt.
    Close Connection
    ${result_cli}=    Wait For Process    handle=dummy_cli    timeout=1 s    on_timeout=terminate
    Log    ${result_cli.stdout}
    Log    ${result_cli.stderr}
    Should Be Equal As Integers    ${result_cli.rc}    0

Open Magik Connection with special prompt
    [Arguments]    ${prompt}    ${port}=${DUMMY_CLI_PORT}    ${host}=localhost
    Start Dummy Remote Cli    prompt=${prompt}
    ${out}=    Open Magik Connection    host=${host}    port=${port}
    RETURN    ${out}
