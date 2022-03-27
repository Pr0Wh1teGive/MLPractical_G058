# Install by PiP

```shell
python -m pip install visualdl -i https://mirror.baidu.com/pypi/simple
```

# Install by Code

```
git clone https://github.com/PaddlePaddle/VisualDL.git
cd VisualDL

python setup.py bdist_wheel
pip install --upgrade dist/visualdl-*.whl
```

Please note that Python 2 is no longer maintained officially since January 1, 2020. VisualDL now only supports Python 3 in order to ensure the usability of codes.


# Launch Panel

## Launch by Command Line

Use the command line to launch the VisualDL panel：

```python
visualdl --logdir <dir_1, dir_2, ... , dir_n> --model <model_file> --host <host> --port <port> --cache-timeout <cache_timeout> --language <language> --public-path <public_path> --api-only
```

Parameter details:

| parameters      | meaning                                                      |
| --------------- | ------------------------------------------------------------ |
| --logdir        | Set one or more directories of the log. All the logs in the paths or subdirectories will be displayed on the VisualDL Board indepentently. |
| --model         | Set a path to the model file (not a directory). VisualDL will visualize the model file in Graph page. PaddlePaddle、ONNX、Keras、Core ML、Caffe and other model formats are supported. Please refer to [Graph - Functional Instructions](./docs/components/README.md#functional-instructions-2). |
| --host          | Specify IP address. The default value is `127.0.0.1`. Specify it as `0.0.0.0` or public IP address so that other machines can visit VisualDL Board.       |
| --port          | Set the port. The default value is `8040`.                   |
| --cache-timeout | Cache time of the backend. During the cache time, the front end requests the same URL multiple times, and then the returned data are obtained from the cache. The default cache time is 20 seconds. |
| --language      | The language of the VisualDL panel. Language can be specified as 'en' or 'zh', and the default is the language used by the browser. |
| --public-path   | The URL path of the VisualDL panel. The default path is '/app', meaning that the access address is 'http://&lt;host&gt;:&lt;port&gt;/app'. |
| --api-only      | Decide whether or not to provide only API. If this parameter is set, VisualDL will only provides API service without displaying the web page, and the API address is 'http://&lt;host&gt;:&lt;port&gt;/&lt;public_path&gt;/api'. Additionally, If the public_path parameter is not specified, the default address is 'http://&lt;host&gt;:&lt;port&gt;/api'. |

To visualize the log file generated in the previous step, developers can launch the panel through the command:

```
visualdl --logdir ./log
```
