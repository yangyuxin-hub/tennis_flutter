import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 国家代码选择页面
class CountryCodePickerScreen extends StatefulWidget {
  final String currentCode;

  const CountryCodePickerScreen({
    super.key,
    this.currentCode = '+86',
  });

  @override
  State<CountryCodePickerScreen> createState() =>
      _CountryCodePickerScreenState();
}

class _CountryCodePickerScreenState extends State<CountryCodePickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<CountryCode> _filteredCountries = [];
  String _selectedCode = '+86';

  @override
  void initState() {
    super.initState();
    _selectedCode = widget.currentCode;
    _filteredCountries = _allCountries;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = _allCountries;
      } else {
        _filteredCountries = _allCountries
            .where((country) =>
                country.name.toLowerCase().contains(query.toLowerCase()) ||
                country.code.contains(query),)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A4E8D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A4E8D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '热门',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
              ),
              decoration: InputDecoration(
                hintText: '搜索国家或地区',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 16.sp,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              onChanged: _filterCountries,
            ),
          ),

          // 国家列表
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCountries.length,
              itemBuilder: (context, index) {
                final country = _filteredCountries[index];
                final isSelected = country.code == _selectedCode;

                return InkWell(
                  onTap: () {
                    Navigator.of(context).pop(country.code);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            country.name,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Text(
                          country.code,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        if (isSelected) ...[
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20.w,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 国家代码数据模型
class CountryCode {
  final String name;
  final String code;

  const CountryCode(this.name, this.code);
}

/// 国家代码列表（常用国家）
final List<CountryCode> _allCountries = [
  // 热门
  const CountryCode('中国', '+86'),
  const CountryCode('中国香港地区', '+852'),
  const CountryCode('中国澳门地区', '+853'),
  const CountryCode('中国台湾地区', '+886'),
  const CountryCode('美国', '+1'),
  const CountryCode('加拿大', '+1'),
  const CountryCode('澳大利亚', '+61'),
  const CountryCode('英国', '+44'),
  const CountryCode('法国', '+33'),
  const CountryCode('日本', '+81'),
  const CountryCode('韩国', '+82'),
  const CountryCode('新加坡', '+65'),

  // A
  const CountryCode('安道尔', '+376'),
  const CountryCode('奥地利', '+43'),
  const CountryCode('澳大利亚', '+61'),
  const CountryCode('阿尔巴尼亚', '+355'),
  const CountryCode('阿尔及利亚', '+213'),
  const CountryCode('爱尔兰', '+353'),
  const CountryCode('阿曼', '+968'),
  const CountryCode('安哥拉', '+244'),
  const CountryCode('安圭拉', '+1'),
  const CountryCode('阿根廷', '+54'),
  const CountryCode('埃及', '+20'),

  // B-E
  const CountryCode('巴西', '+55'),
  const CountryCode('巴拿马', '+507'),
  const CountryCode('比利时', '+32'),
  const CountryCode('冰岛', '+354'),
  const CountryCode('波兰', '+48'),
  const CountryCode('丹麦', '+45'),
  const CountryCode('德国', '+49'),
  const CountryCode('俄罗斯', '+7'),

  // F-M
  const CountryCode('法国', '+33'),
  const CountryCode('芬兰', '+358'),
  const CountryCode('哥伦比亚', '+57'),
  const CountryCode('荷兰', '+31'),
  const CountryCode('韩国', '+82'),
  const CountryCode('加拿大', '+1'),
  const CountryCode('柬埔寨', '+855'),
  const CountryCode('捷克', '+420'),
  const CountryCode('克罗地亚', '+385'),
  const CountryCode('肯尼亚', '+254'),
  const CountryCode('老挝', '+856'),
  const CountryCode('黎巴嫩', '+961'),
  const CountryCode('卢森堡', '+352'),
  const CountryCode('罗马尼亚', '+40'),
  const CountryCode('马来西亚', '+60'),
  const CountryCode('马尔代夫', '+960'),
  const CountryCode('美国', '+1'),
  const CountryCode('蒙古', '+976'),
  const CountryCode('孟加拉', '+880'),
  const CountryCode('缅甸', '+95'),
  const CountryCode('摩洛哥', '+212'),
  const CountryCode('墨西哥', '+52'),

  // N-Z
  const CountryCode('南非', '+27'),
  const CountryCode('尼泊尔', '+977'),
  const CountryCode('挪威', '+47'),
  const CountryCode('葡萄牙', '+351'),
  const CountryCode('日本', '+81'),
  const CountryCode('瑞典', '+46'),
  const CountryCode('瑞士', '+41'),
  const CountryCode('沙特阿拉伯', '+966'),
  const CountryCode('斯里兰卡', '+94'),
  const CountryCode('泰国', '+66'),
  const CountryCode('土耳其', '+90'),
  const CountryCode('文莱', '+673'),
  const CountryCode('乌克兰', '+380'),
  const CountryCode('西班牙', '+34'),
  const CountryCode('希腊', '+30'),
  const CountryCode('新加坡', '+65'),
  const CountryCode('新西兰', '+64'),
  const CountryCode('匈牙利', '+36'),
  const CountryCode('意大利', '+39'),
  const CountryCode('印度', '+91'),
  const CountryCode('印度尼西亚', '+62'),
  const CountryCode('英国', '+44'),
  const CountryCode('约旦', '+962'),
  const CountryCode('越南', '+84'),
  const CountryCode('智利', '+56'),
];
