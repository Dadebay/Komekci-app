import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// Maps legacy Material icon choices to the app's HugeIcons set.
class AppIcon extends StatelessWidget {
  const AppIcon(this.material, {super.key, this.color, this.size = 24});

  final IconData material;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) => HugeIcon(
    icon: switch (material) {
      Icons.content_cut => HugeIcons.strokeRoundedScissor,
      Icons.calendar_month_outlined ||
      Icons.calendar_today_outlined => HugeIcons.strokeRoundedCalendar01,
      Icons.home_outlined => HugeIcons.strokeRoundedHome01,
      Icons.person_outline ||
      Icons.face_2_outlined => HugeIcons.strokeRoundedUser,
      Icons.account_box_outlined => HugeIcons.strokeRoundedUserAccount,
      Icons.people_outline => HugeIcons.strokeRoundedUserGroup,
      Icons.workspace_premium_outlined => HugeIcons.strokeRoundedUserGroup,
      Icons.search => HugeIcons.strokeRoundedSearch01,
      Icons.phone_outlined => HugeIcons.strokeRoundedCall,
      Icons.location_on_outlined => HugeIcons.strokeRoundedLocation01,
      Icons.edit_outlined => HugeIcons.strokeRoundedEdit02,
      Icons.photo_camera_outlined => HugeIcons.strokeRoundedCamera01,
      Icons.image_outlined => HugeIcons.strokeRoundedImage02,
      Icons.delete_outline => HugeIcons.strokeRoundedDelete02,
      Icons.save_outlined => HugeIcons.strokeRoundedFloppyDisk,
      Icons.help_outline => HugeIcons.strokeRoundedHelpCircle,
      Icons.menu => HugeIcons.strokeRoundedMenu01,
      Icons.expand_more => HugeIcons.strokeRoundedArrowDown01,
      Icons.logout => HugeIcons.strokeRoundedLogout01,
      Icons.history => HugeIcons.strokeRoundedClock01,
      Icons.spa_outlined => HugeIcons.strokeRoundedFlower,
      Icons.schedule_outlined => HugeIcons.strokeRoundedClock01,
      Icons.info_outline => HugeIcons.strokeRoundedInformationCircle,
      Icons.warning_amber_rounded => HugeIcons.strokeRoundedAlert01,
      Icons.smartphone_outlined => HugeIcons.strokeRoundedSmartPhone01,
      Icons.sim_card_outlined => HugeIcons.strokeRoundedSimcard01,
      Icons.credit_card_outlined => HugeIcons.strokeRoundedCreditCard,
      Icons.account_balance_outlined => HugeIcons.strokeRoundedBank,
      Icons.atm_outlined => HugeIcons.strokeRoundedAtm01,
      Icons.savings_outlined => HugeIcons.strokeRoundedMoneyBag01,
      Icons.payments_outlined => HugeIcons.strokeRoundedCash01,
      Icons.account_balance_wallet_outlined => HugeIcons.strokeRoundedWallet01,
      Icons.chat_bubble_outline => HugeIcons.strokeRoundedCustomerSupport,
      Icons.coffee_outlined => HugeIcons.strokeRoundedCoffee02,
      Icons.event_busy_outlined => HugeIcons.strokeRoundedCalendarOff,
      Icons.timer_outlined => HugeIcons.strokeRoundedTimer02,
      Icons.send_outlined => HugeIcons.strokeRoundedSendToMobile,
      Icons.groups_outlined => HugeIcons.strokeRoundedUserGroup,
      Icons.lock_outline => HugeIcons.strokeRoundedSquareLock01,
      Icons.verified_user_outlined => HugeIcons.strokeRoundedSecurityCheck,
      Icons.link_outlined => HugeIcons.strokeRoundedLink01,
      Icons.person_add_alt ||
      Icons.person_add_alt_1 => HugeIcons.strokeRoundedUserAdd01,
      Icons.emoji_events_outlined => HugeIcons.strokeRoundedCrown,
      Icons.star_border => HugeIcons.strokeRoundedStar,
      Icons.filter_list => HugeIcons.strokeRoundedFilter,
      Icons.flag_outlined || Icons.flag => HugeIcons.strokeRoundedFlag01,
      Icons.more_vert => HugeIcons.strokeRoundedMoreVertical,
      Icons.sticky_note_2_outlined => HugeIcons.strokeRoundedStickyNote01,
      Icons.bar_chart_outlined => HugeIcons.strokeRoundedChartBarBig,
      Icons.notifications_none || Icons.notifications_active_outlined =>
        HugeIcons.strokeRoundedNotification01,
      Icons.arrow_forward => HugeIcons.strokeRoundedArrowRight01,
      Icons.arrow_back => HugeIcons.strokeRoundedArrowLeft01,
      Icons.arrow_outward => HugeIcons.strokeRoundedArrowUpRight01,
      Icons.chevron_right => HugeIcons.strokeRoundedArrowRight01,
      Icons.chevron_left => HugeIcons.strokeRoundedArrowLeft01,
      Icons.expand_less => HugeIcons.strokeRoundedArrowUp01,
      Icons.add || Icons.add_circle_outline => HugeIcons.strokeRoundedAdd01,
      Icons.close => HugeIcons.strokeRoundedCancel01,
      Icons.check ||
      Icons.check_circle ||
      Icons.check_circle_outline => HugeIcons.strokeRoundedCheckmarkCircle01,
      Icons.wifi_rounded => HugeIcons.strokeRoundedWifi01,
      Icons.wifi_off_rounded => HugeIcons.strokeRoundedWifiOff01,
      Icons.language => HugeIcons.strokeRoundedLanguageCircle,
      Icons.switch_account_outlined => HugeIcons.strokeRoundedUserSwitch,
      Icons.swap_horiz => HugeIcons.strokeRoundedArrowLeftRight,
      Icons.shield_outlined => HugeIcons.strokeRoundedShield01,
      Icons.favorite_border ||
      Icons.favorite => HugeIcons.strokeRoundedFavourite,
      Icons.brush_outlined => HugeIcons.strokeRoundedPaintBrush01,
      Icons.face_retouching_natural => HugeIcons.strokeRoundedBlushBrush01,
      Icons.remove_red_eye_outlined => HugeIcons.strokeRoundedEye,
      Icons.bed_outlined => HugeIcons.strokeRoundedBed,
      Icons.grid_view_outlined => HugeIcons.strokeRoundedGridView,
      Icons.person_search_outlined => HugeIcons.strokeRoundedUserSearch01,
      Icons.person_off_outlined => HugeIcons.strokeRoundedUserRemove01,
      Icons.task_alt_outlined => HugeIcons.strokeRoundedTaskDone01,
      Icons.bookmark_border ||
      Icons.bookmark => HugeIcons.strokeRoundedBookmark02,
      Icons.sms_outlined => HugeIcons.strokeRoundedSmsCode,
      Icons.refresh => HugeIcons.strokeRoundedRefresh,
      Icons.error_outline => HugeIcons.strokeRoundedAlertCircle,
      Icons.cancel => HugeIcons.strokeRoundedCancelCircle,
      Icons.alternate_email => HugeIcons.strokeRoundedMailAtSign01,
      Icons.camera_alt_outlined => HugeIcons.strokeRoundedCamera01,
      Icons.music_note_outlined => HugeIcons.strokeRoundedMusicNote01,
      Icons.copy_outlined => HugeIcons.strokeRoundedCopy01,
      Icons.delete_forever_outlined => HugeIcons.strokeRoundedDelete02,
      Icons.inbox_outlined => HugeIcons.strokeRoundedInbox,
      Icons.link_off => HugeIcons.strokeRoundedUnlink01,
      Icons.more_horiz => HugeIcons.strokeRoundedMoreHorizontal,
      Icons.person_add_alt_1_outlined => HugeIcons.strokeRoundedUserAdd01,
      Icons.phone_android_outlined => HugeIcons.strokeRoundedSmartPhone01,
      Icons.receipt_long_outlined => HugeIcons.strokeRoundedInvoice01,
      Icons.star_outline => HugeIcons.strokeRoundedStar,
      Icons.support_agent_outlined => HugeIcons.strokeRoundedCustomerSupport,
      Icons.hourglass_empty ||
      Icons.hourglass_top_outlined ||
      Icons.hourglass_top_rounded => HugeIcons.strokeRoundedHourglass,
      Icons.auto_awesome_outlined => HugeIcons.strokeRoundedSparkles,
      Icons.format_list_numbered => HugeIcons.strokeRoundedLeftToRightListNumber,
      _ => HugeIcons.strokeRoundedCircle,
    },
    color: color,
    size: size,
  );
}
