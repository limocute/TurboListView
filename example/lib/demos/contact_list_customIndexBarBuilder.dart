import 'dart:convert';
import 'package:turbolistview/turbolistview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lpinyin/lpinyin.dart';
import 'contact_model.dart';
import 'package:turbolistview/src/custom_index_bar.dart';
  /// 用作测试用
const List<String> INDEX_DATA_0 = ['★', '♀', '↑', '@', 'A', 'B', 'C', 'D'];
const List<String> INDEX_DATA_1 = ['E', 'F', 'G', 'H', 'I', 'J', 'K', 'L'];
const List<String> INDEX_DATA_2 = ['M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T'];
const List<String> INDEX_DATA_3 = ['U', 'V', 'W', 'X', 'Y', 'Z', '#', '↓'];
const List<String> IGNORE_TAGS = [];

class ContactListRoute3 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _ContactListRouteState3();
  }
}

class _ContactListRouteState3 extends State<ContactListRoute3> {
  List<ContactInfo> _contacts = List();

  int _suspensionHeight = 40;
  int _itemHeight = 60;
  String _hitTag = "";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    //加载联系人列表
    rootBundle.loadString('assets/data/contacts.json').then((value) {
      List list = json.decode(value);
      list.forEach((value) {
        _contacts.add(ContactInfo(name: value['name']));
      });
      _handleList(_contacts);
      setState(() {});
    });
  }

  void _handleList(List<ContactInfo> list) {
    if (list == null || list.isEmpty) return;
    for (int i = 0, length = list.length; i < length; i++) {
      String pinyin = PinyinHelper.getPinyinE(list[i].name);
      String tag = pinyin.substring(0, 1).toUpperCase();
      list[i].namePinyin = pinyin;
      if (RegExp("[A-Z]").hasMatch(tag)) {
        list[i].tagIndex = tag;
      } else {
        list[i].tagIndex = "#";
      }
    }
    //根据A-Z排序
    SuspensionUtil.sortListBySuspensionTag(_contacts);
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ClipOval(
              child: Image.asset(
            "./assets/images/avatar.png",
            width: 80.0,
          )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "远行",
              textScaleFactor: 1.2,
            ),
          ),
          Text("+86 182-286-44678"),
        ],
      ),
    );
  }

  Widget _buildSusWidget(String susTag) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      height: _suspensionHeight.toDouble(),
      width: double.infinity,
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          Text(
            '$susTag',
            textScaleFactor: 1.2,
          ),
          Expanded(
              child: Divider(
            height: .0,
            indent: 10.0,
          ))
        ],
      ),
    );
  }
  
  /// 索引标签被点击
  void _onSusTagChanged(String tag) {
    setState(() {
      _suspensionTag = tag;
    });
  }
  
  Widget _buildListItem(ContactInfo model) {
    String susTag = model.getSuspensionTag();
    return Column(
      children: <Widget>[
        Offstage(
          offstage: model.isShowSuspension != true,
          child: _buildSusWidget(susTag),
        ),
        SizedBox(
          height: _itemHeight.toDouble(),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(model.name[0]),
            ),
            title: Text(model.name),
            onTap: () {
              print("OnItemClick: $model");
              Navigator.pop(context, model);
            },
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return TurboListView(
      data: _contacts,
      itemBuilder: (context, model) => _buildListItem(model),
      suspensionWidget: _buildSusWidget2(_suspensionTag, isFloat: true),
      onSusTagChanged: _onSusTagChanged,
      isUseRealIndex: true,
      itemHeight: _itemHeight,
      suspensionHeight: _suspensionHeight,
      header: AzListViewHeader(
          height: 180,
          builder: (context) {
            return _buildHeader();
          }),
      indexBarBuilder: (BuildContext context, List<String> tags,
          IndexBarTouchCallback onTouch) {
        return _buildCustomIndexBarByBuilder(context,tags,onTouch);//自定义indexbar
      },
      showIndexHint:false,//隐藏默认提供的
     
    );
  }

  /// 构建悬浮部件
  /// [susTag] 标签名称
  /// [isFloat] 是否悬浮
  Widget _buildSusWidget2(String susTag, {bool isFloat = false}) {
    return Container(
      height: _suspensionHeight.toDouble(),
      padding: EdgeInsets.only(left: 51),
      decoration: BoxDecoration(
        color: isFloat ? Colors.white : Colors.blue,
        border: isFloat
            ? Border(bottom: BorderSide(color: Color(0xFFE6E6E6), width: 0.5))
            : null,
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        '$susTag',
        softWrap: false,
        style: TextStyle(
          fontSize: 39,
          color: isFloat ? Colors.red : Color(0xff777777),
        ),
      ),
    );
  }
  String _suspensionTag='';
  
  /// 🔥🔥🔥 构建自定义IndexBar by builder  使用Builder的形式控件 更加强大 更高定制度
  Widget _buildCustomIndexBarByBuilder(BuildContext context,
      List<String> tagList, IndexBarTouchCallback onTouch) {
    return CustomIndexBar(
      data: tagList,
      tag: _suspensionTag,
      onTouch: onTouch,
      indexBarTagBuilder: (context, tag, indexModel) {
        return _buildIndexBarTagWidget(context, tag, indexModel);
      },
      indexBarHintBuilder: (context, tag, indexModel) {
        return _buildIndexBarHintWidget(context, tag, indexModel);
      },
    );
  }

  /// 构建tag
  Widget _buildIndexBarTagWidget(
      BuildContext context, String tag, IndexBarDetails indexModel) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _fetchColor(tag, indexModel),
        borderRadius: BorderRadius.circular(7),
      ),
      child: _buildTagWidget(tag, indexModel),
      width: 14.0,
      height: 14.0,
    );
  }

  /// 获取背景色
  Color _fetchColor(String tag, IndexBarDetails indexModel) {
    Color color;
    if (INDEX_DATA_0.indexOf(tag) != -1) {
      // 灰
      // color = Color(0xFFC9C9C9);
      // 黄
      color = Color(0xFFFFC300);
    } else if (INDEX_DATA_1.indexOf(tag) != -1) {
      // 红
      color = Color(0xFFFA5151);
    } else if (INDEX_DATA_2.indexOf(tag) != -1) {
      // 绿
      color = Color(0xFF07C160);
    } else {
      // 蓝
      color = Color(0xFF10AEFF);
    }
    if (indexModel.tag == tag) {
      return IGNORE_TAGS.indexOf(tag) != -1 ? Colors.transparent : color;
    }
    return Colors.transparent;
  }

  /// 构建某个tag
  Widget _buildTagWidget(String tag, IndexBarDetails indexModel) {
    Color textColor;
    Color selTextColor;
    if (INDEX_DATA_0.indexOf(tag) != -1) {
      // 浅黑 Color(0xFF555555)
      textColor = Color(0xFFFFC300);
      selTextColor = Colors.white;
    } else if (INDEX_DATA_1.indexOf(tag) != -1) {
      // 红色
      textColor = Color(0xFFFA5151);
      selTextColor = Colors.white;
    } else if (INDEX_DATA_2.indexOf(tag) != -1) {
      // 绿色
      textColor = Color(0xFF07C160);
      selTextColor = Colors.white;
    } else {
      // 蓝色
      textColor = Color(0xFF10AEFF);
      selTextColor = Colors.white;
    }
    // 当前选中的tag, 也就是高亮的场景
    if (indexModel.tag == tag) {
      final isIgnore = IGNORE_TAGS.indexOf(tag) != -1;
      // 如果是忽略
      if (isIgnore) {
        // 你可以针对某个标签 做更加高的定制
        if (tag == '♀') {
          // 返回映射的部件
          return Icon(Icons.search);
        } else {
          // 返回默认的部件
          return Text(
            tag,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.0,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          );
        }
      } else {
        // 不忽略，则显示高亮组件
        if (tag == '♀') {
          // 返回映射高亮的部件
          return Icon(Icons.search);
        } else {
          // 返回默认的部件
          return Text(
            tag,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.0,
              color: selTextColor,
              fontWeight: FontWeight.w500,
            ),
          );
        }
      }
    }
    // 非高亮场景
    // 获取mapTag
    if (tag == '♀') {
      // 返回映射的部件
      return Icon(Icons.search);
    } else {
      // 返回默认的部件

      return Text(
        tag,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10.0,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      );
    }
  }


  /// 构建Hint
  Widget _buildIndexBarHintWidget(
      BuildContext context, String tag, IndexBarDetails indexModel) {
    // 图片名
    String imageName;
    if (INDEX_DATA_0.indexOf(tag) != -1) {
      // 浅黑
      imageName = 'contact_index_bar_bubble_0.png';
    } else if (INDEX_DATA_1.indexOf(tag) != -1) {
      // 红色
      imageName = 'contact_index_bar_bubble_1.png';
    } else if (INDEX_DATA_2.indexOf(tag) != -1) {
      // 绿色
      imageName = 'contact_index_bar_bubble_2.png';
    } else {
      // 蓝色
      imageName = 'contact_index_bar_bubble_3.png';
    }
    imageName='ContactIndexShape.png';
    return Positioned(
      left: -80,
      top: -(64 - 16) * 0.5,
      child: Offstage(
        offstage: _fetchOffstage(tag, indexModel),
        child: Container(
          width: 64.0,
          height: 64.0,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/$imageName'),
              fit: BoxFit.contain,
            ),
          ),
          alignment: Alignment(-0.25, 0.0),
          child: _buildHintChildWidget(tag, indexModel),
        ),
      ),
    );
  }

  /// 构建某个hint中子部件
  Widget _buildHintChildWidget(String tag, IndexBarDetails indexModel) {
    if (tag == '♀') {
      // 返回映射高亮的部件
      return Icon(Icons.search);
    }
    return Text(
      tag,
      style: TextStyle(
        color: Colors.white70,
        fontSize: 30.0,
        fontWeight: FontWeight.w700,
      ),
    );
  }

   // 获取Offstage 是否隐居幕后
  bool _fetchOffstage(String tag, IndexBarDetails indexModel) {
    if (indexModel.tag == tag) {
      final List<String> ignoreTags = [];
      return ignoreTags.indexOf(tag) != -1 ? true : !indexModel.isTouchDown;
    }
    return true;
  }

}
