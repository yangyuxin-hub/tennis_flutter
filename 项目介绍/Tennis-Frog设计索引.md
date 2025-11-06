# Tennis-Frog 设计文件索引

## 📋 文件信息

- **文件名称：** Tennis-Frog
- **文件 Key：** `XBUIg5DVwkoLkDFk3FEuRO`
- **Figma 链接：** [查看设计文件](https://www.figma.com/design/XBUIg5DVwkoLkDFk3FEuRO/Tennis-Frog?t=4D5zcaJWxbHCrQZv-0)
- **最后同步：** 2025-11-03

---

## 🎨 设计页面总览

### 📱 01 - 启动页面
- **01-07-splash-screen** - 启动屏幕
  - 节点 ID: `3:58`
  - 状态：待开发
  - 说明：App 启动时的欢迎页面，显示 Logo

### 🔐 02 - 引导页面
- **02-04-onboarding** - 引导页 1
- **02-05-onboarding** - 引导页 2
- **02-06-onboarding** - 引导页 3
  - 状态：待开发
  - 说明：首次使用引导流程

### 🔑 03 - 登录页面
- **03-01-login-blank** - 登录页（空白状态）
- **03-02-login-filled-pass-hide** - 登录页（已填写，密码隐藏）
- **03-03-login-filled-pass-unhide** - 登录页（已填写，密码显示）
- **03-04-login-success-loading-circle** - 登录成功加载中
  - 状态：待开发
  - 对应代码：`mobile/src/screens/auth/LoginScreen.tsx`

### 🔐 04 - 忘记密码流程
- **04-01-forgot-password-email-blank** - 忘记密码（邮箱空白）
- **04-02-forgot-password-email-filled** - 忘记密码（邮箱已填写）
- **04-03-code-verification** - 验证码验证
- **04-04-reset-password-blank** - 重置密码（空白）
- **04-05-reset-password-filled-strong** - 重置密码（强密码）
- **04-06-reset-password-filled-weak** - 重置密码（弱密码）
  - 状态：待开发
  - 对应代码：`mobile/src/screens/auth/ForgotPasswordScreen.tsx`

### ✍️ 05 - 注册页面
- **05-01-signup-blank** - 注册页（空白状态）
- **05-02-signup-filled-pass-strong** - 注册页（强密码）
- **05-03-signup-filled-pass-weak** - 注册页（弱密码）
- **05-04-signup-filled-pass-weak-failed** - 注册失败（弱密码）
- **05-05-signup-success-loading-circle** - 注册成功加载中
  - 状态：待开发
  - 对应代码：`mobile/src/screens/auth/RegisterScreen.tsx`

### 🏠 06 - 首页动态流
- **06-01-home-short** - 首页（短内容）
- **06-02-home-long** - 首页（长内容，滚动）
- **06-03-home-search** - 首页搜索
  - 状态：🚧 核心功能，优先开发
  - 对应代码：`mobile/src/screens/feed/FeedScreen.tsx`
  - 功能：显示动态流，点赞、评论、分享

### 🎾 07 - 约球功能
- **07-01-explore game** - 浏览比赛
- **07-01-Join a game** - 加入比赛
  - 状态：🚧 核心功能，优先开发
  - 对应代码：`mobile/src/screens/matches/MatchesScreen.tsx`
  - 功能：约球列表、筛选、加入

### 💬 08 - 聊天功能
- **08-01-chats** - 聊天列表
- **08-02-chats-slide-delete** - 聊天列表（滑动删除）
- **08-03-chats-delete** - 删除确认
- **08-04-chats-delete-success** - 删除成功
- **08-05-chats-delete-failed** - 删除失败
- **08-06-chat-room** - 聊天室
- **08-07-chat-room-typing** - 聊天室（输入中）
  - 状态：待开发
  - 对应代码：`mobile/src/screens/chat/ChatScreen.tsx`

### 👤 09 - 个人中心
- **09-01-profile-my-account** - 我的账号
- **09-02-profile-others-account-unfollowed** - 他人账号（未关注）
- **09-03-profile-others-account-unfollowed** - 他人账号（已关注）
  - 状态：待开发
  - 对应代码：`mobile/src/screens/profile/ProfileScreen.tsx`

### 📤 10 - 发布动态
- **10-04-upload-caption-filled** - 上传（标题已填写）
- **10-05-upload-loading** - 上传加载中
- **10-06-upload-failed** - 上传失败
  - 状态：🚧 核心功能
  - 对应代码：`mobile/src/screens/post/CreatePostScreen.tsx`

### 🔔 11 - 通知
- **11-01-notifications** - 通知列表（有通知）
- **11-02-notifications-blank** - 通知列表（空状态）
  - 状态：待开发
  - 对应代码：`mobile/src/screens/notifications/NotificationsScreen.tsx`

### ⚙️ 12 - 设置
- **12-01-settings** - 设置页面
  - 状态：待开发
  - 对应代码：`mobile/src/screens/settings/SettingsScreen.tsx`

### 💬 13 - 评论
- **13-01-comment-post** - 帖子评论
  - 状态：🚧 核心功能
  - 对应代码：`mobile/src/screens/feed/CommentScreen.tsx`

---

## 🎨 设计系统

### 颜色规范

根据设计文件提取的主要颜色：

```typescript
// design-tokens/colors.ts

export const colors = {
  // 主色调 - 深绿色（品牌色）
  primary: {
    main: '#274125',      // RGB(39, 65, 37) - 从启动页背景提取
    dark: '#1a2e19',
    light: '#3d5a3b',
  },
  
  // 辅助色
  secondary: {
    tennis: '#7CB342',    // 网球绿
    accent: '#4CAF50',    // 强调色
  },
  
  // 灰度
  gray: {
    light: '#DADADA',     // RGB(218, 218, 218) - 从设计中提取
    medium: '#888888',
    dark: '#383838',      // RGB(56, 56, 56)
  },
  
  // 功能色
  background: {
    main: '#FFFFFF',
    secondary: '#F5F5F5',
    dark: '#274125',
  },
  
  text: {
    primary: '#000000',
    secondary: '#666666',
    white: '#FFFFFF',
  },
  
  // 状态色
  status: {
    success: '#4CAF50',
    error: '#F44336',
    warning: '#FF9800',
    info: '#2196F3',
  },
};
```

### 字体规范

```typescript
// design-tokens/typography.ts

export const typography = {
  // 标题
  h1: {
    fontSize: 28,
    fontWeight: 'bold',
    lineHeight: 36,
  },
  
  h2: {
    fontSize: 24,
    fontWeight: 'bold',
    lineHeight: 32,
  },
  
  h3: {
    fontSize: 20,
    fontWeight: '600',
    lineHeight: 28,
  },
  
  // 正文
  body: {
    fontSize: 16,
    fontWeight: 'normal',
    lineHeight: 24,
  },
  
  bodySmall: {
    fontSize: 14,
    fontWeight: 'normal',
    lineHeight: 20,
  },
  
  // 说明文字
  caption: {
    fontSize: 12,
    fontWeight: 'normal',
    lineHeight: 16,
  },
  
  // 按钮
  button: {
    fontSize: 16,
    fontWeight: '600',
    lineHeight: 20,
  },
};
```

### 间距规范

```typescript
// design-tokens/spacing.ts

export const spacing = {
  xs: 4,    // 最小间距
  sm: 8,    // 小间距
  md: 16,   // 中等间距（标准）
  lg: 24,   // 大间距
  xl: 32,   // 超大间距
  xxl: 48,  // 特大间距
};

export const radius = {
  sm: 4,    // 小圆角
  md: 8,    // 中等圆角
  lg: 16,   // 大圆角
  full: 999, // 完全圆形
};
```

### 屏幕尺寸

```typescript
// design-tokens/dimensions.ts

export const screen = {
  width: 375,   // 设计稿宽度（iPhone SE/8）
  height: 812,  // 设计稿高度（iPhone X/11/12）
};
```

---

## 📦 组件库

### Logo 组件
- **组件 ID：** `2:31`
- **变体：** White / Dark
- **使用场景：** 启动页、导航栏

### Button 组件
- **Primary Button** - 主按钮
- **Secondary Button** - 次要按钮
- **Outline Button** - 轮廓按钮
- **Text Button** - 文本按钮

### Input 组件
- **Text Input** - 文本输入
- **Password Input** - 密码输入（带显示/隐藏切换）
- **Search Input** - 搜索输入

### Card 组件
- **Post Card** - 动态卡片
- **Match Card** - 约球卡片
- **User Card** - 用户卡片

---

## 🚀 开发优先级

### 第一阶段：核心认证流程（1-2周）
- [x] ✅ Figma 设计已同步
- [ ] 01-启动页面
- [ ] 02-引导页面
- [ ] 03-登录页面
- [ ] 05-注册页面
- [ ] 04-忘记密码流程

### 第二阶段：主要功能（3-4周）
- [ ] 06-首页动态流 ⭐ 核心
- [ ] 10-发布动态 ⭐ 核心
- [ ] 13-评论功能 ⭐ 核心
- [ ] 07-约球功能 ⭐ 核心

### 第三阶段：社交功能（2-3周）
- [ ] 09-个人中心
- [ ] 08-聊天功能
- [ ] 11-通知功能

### 第四阶段：完善功能（1-2周）
- [ ] 12-设置页面
- [ ] 优化和调整
- [ ] 性能优化

---

## 📸 如何导出设计资源

### 导出单个页面截图

**示例：导出启动页**
```
节点 ID: 3:58
页面名称: 01-07-splash-screen
```

告诉我："导出启动页截图"，我会帮你导出 PNG 格式的图片。

### 导出所有页面

我可以批量导出所有主要页面作为开发参考图。

### 导出图标和组件

可以导出 SVG 格式的图标，直接用于代码中。

---

## 🔄 设计同步流程

### 当设计更新时

1. **通知我设计已更新**
   ```
   "Figma 设计已更新，帮我重新同步"
   ```

2. **我会自动**
   - 获取最新版本的设计文件
   - 对比变更内容
   - 更新此索引文档

3. **你需要**
   - 查看变更内容
   - 更新对应的代码实现

---

## 💡 开发建议

### 1. 按模块开发
不要一次性实现所有页面，而是按功能模块逐个完成：
```
认证模块 → 动态模块 → 约球模块 → 社交模块
```

### 2. 复用组件
提取可复用组件，避免重复代码：
```typescript
// 例如：Button、Card、Input 等基础组件
import { Button } from '@/components/common/Button';
```

### 3. 建立映射关系
在代码中注释对应的 Figma 页面：
```typescript
/**
 * 登录页面
 * @figma 03-01-login-blank
 * @node-id 节点ID
 */
const LoginScreen = () => {
  // ...
};
```

### 4. 使用设计 Token
统一使用 design-tokens 中定义的颜色、字体、间距：
```typescript
import { colors, typography, spacing } from '@/design-tokens';

const styles = StyleSheet.create({
  container: {
    backgroundColor: colors.background.main,
    padding: spacing.md,
  },
  title: {
    fontSize: typography.h1.fontSize,
    color: colors.text.primary,
  },
});
```

---

## 📞 需要帮助？

### 导出设计资源
告诉我你想导出哪个页面：
```
"导出登录页截图"
"导出所有约球相关页面"
"导出 Logo 为 SVG"
```

### 查看设计细节
告诉我你想了解什么：
```
"首页动态卡片的尺寸是多少？"
"登录按钮的颜色值是什么？"
"这个页面的间距规范是怎样的？"
```

### 提取样式信息
```
"提取首页的颜色方案"
"查看所有按钮样式"
"导出完整的设计规范"
```

---

## 📊 开发进度跟踪

| 模块 | 页面数 | 状态 | 进度 |
|------|--------|------|------|
| 启动引导 | 4 | ⏳ 待开发 | 0% |
| 认证流程 | 11 | ⏳ 待开发 | 0% |
| 首页动态 | 3 | ⏳ 待开发 | 0% |
| 约球功能 | 2 | ⏳ 待开发 | 0% |
| 聊天功能 | 7 | ⏳ 待开发 | 0% |
| 个人中心 | 3 | ⏳ 待开发 | 0% |
| 发布功能 | 3 | ⏳ 待开发 | 0% |
| 通知设置 | 3 | ⏳ 待开发 | 0% |
| 评论功能 | 1 | ⏳ 待开发 | 0% |

**总计：** 37 个主要页面

---

**准备好开始开发了吗？告诉我你想从哪个模块开始，我帮你导出对应的设计资源！** 🎾🚀

