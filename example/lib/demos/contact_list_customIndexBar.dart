import 'dart:convert';
import 'package:turbolistview/turbolistview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lpinyin/lpinyin.dart';
import 'contact_model.dart';
import 'package:turbolistview/src/custom_index_bar.dart';

class ContactListRoute2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _ContactListRouteState2();
  }
}

class _ContactListRouteState2 extends State<ContactListRoute2> {
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
  /// 构建悬浮部件
  /// [susTag] 标签名称
  /// [isFloat] 是否悬浮
  Widget _buildSusWidget2(String susTag, {bool isFloat = false}) {
    return Container(
      height: _suspensionHeight.toDouble(),
      padding: EdgeInsets.only(left: 51.0),
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
          fontSize: 39.0,
          color: isFloat ? Colors.red : Color(0xff777777),
        ),
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
        return _buildCustomIndexBarByDefault(context,tags,onTouch);//自定义indexbar
      },
      indexHintBuilder: (context, hint) {
        return Container(
          alignment: Alignment.center,
          width: 60.0,
          height: 60.0,
          decoration: BoxDecoration(
            color: Colors.blue[700].withAlpha(200),
            shape: BoxShape.circle,
          ),
          child:
              Text(hint, style: TextStyle(color: Colors.white, fontSize: 30.0)),
        );
      },
    );
  }
  String _suspensionTag='';
  /// 构建自定义IndexBar by default
  Widget _buildCustomIndexBarByDefault(BuildContext context,
      List<String> tagList, IndexBarTouchCallback onTouch) {
    return CustomIndexBar(
      data: tagList,
      tag: _suspensionTag,
      hintOffsetX: -80,
      ignoreTags: ['♀'],//忽略的Tags，这些忽略Tag, 不会高亮显示，点击或长按 不会弹出 tagHint
      // selectedTagColor: Colors.red,
      //以下三个时针对某个key设置指定图片
      // mapTag: {
      //   "♀": new SvgPicture.asset(
      //     Constant.assetsImagesSearch + 'icons_filled_search.svg',
      //     color: Color(0xFF555555),
      //     width: 12,
      //     height: 12,
      //   ),
      // },
      // mapSelTag: {
      //   "♀": new SvgPicture.asset(
      //     Constant.assetsImagesSearch + 'icons_filled_search.svg',
      //     color: Color(0xFFFFFFFF),
      //     width: 12,
      //     height: 12,
      //   ),
      // },
      // mapHintTag: {
      //   "♀": new SvgPicture.asset(
      //     Constant.assetsImagesSearch + 'icons_filled_search.svg',
      //     color: Colors.white70,
      //     width: 30,
      //     height: 30,
      //   ),
      // },
      onTouch: onTouch,
    );
  }

}
