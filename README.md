# 说明

一个基于 [OpenResty](https://openresty.org/) 的简易博客系统。

通过 [MarkdownPad2](http://markdownpad.com/) 编写博客内容，并将内容转化成 `HTML` 。

通过 `Git hooks` 对提交的内容过滤，用 `Python` 对 `HTML` 内容进行解析，文章内容入数据库。

通过 `Lua` 提供前端页面展示需要的数据。

详细说明，请看 [结合Markdown和Git,做简单的Blog内容发布](https://kiswo.com/article/1000)。

# 目录结构说明

**assets**

存放静态文件，如： js、css、image等。

`base` 目录是前端 `Bootstrap` 模板的名称，每个模板为一个文件夹，便于随意切换皮肤样式。

**cert**

`HTTPS` 用到的 `key` 文件存放目录。

**config**

`Nginx` 配置文件及其它配置文件存放目录。

**html**

`articles` 目录下存放文章的 `HTML`。

`base` 目录是前端 `Bootstrap` 模板的名称，每个模板为一个文件夹。里面存放模板的 `HTML`。

**lua**

服务支持。

**notes**

博客内容的原始 `Markdown` 文件。

**scripts**

处理脚本。
