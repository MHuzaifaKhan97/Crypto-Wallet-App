import 'package:flutter/material.dart';
import '../runtime/models.dart';
import '../theme/theme.dart';
import '../runtime/motion.dart';
import '../runtime/node.dart';
import '../runtime/node_view.dart';
import 'package:go_router/go_router.dart';
import '../runtime/expr_runtime.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_state.dart';
import '../state/state_scope.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _handleInput(String name, dynamic value) {
    ref.read(appStateProvider.notifier).setVar(name, value);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> _ctx = <String, dynamic>{
      'state': ref.watch(appStateProvider),
    };
    return AppTheme.scope(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Notifications'),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          backgroundColor: parseHexColor(
            kDesignThemeSurface,
            const Color(0xFFFFFFFF),
          ),
          foregroundColor: parseHexColor(
            kDesignThemeTextPrimary,
            const Color(0xFF111827),
          ),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        backgroundColor: AppTheme.background,
        body: SafeArea(
          top: true,
          bottom: false,
          child: ScreenEntrance(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: StateScope(
                state: ref.watch(appStateProvider),
                child: Builder(
                  builder: (context) => buildNode(
                    context,
                    NodeModel.fromJson(<String, dynamic>{
                      'id': 's-notifications__root',
                      'type': 'Column',
                      'props': <String, dynamic>{
                        'crossAxisAlignment': 'stretch',
                        'gap': 16,
                        'scrollable': true,
                      },
                      'children': <Map<String, dynamic>>[
                        <String, dynamic>{
                          'id': 'n-5tvls5dh',
                          'type': 'Column',
                          'props': <String, dynamic>{'gap': 4},
                          'layout': {
                            'margin': {
                              'top': 8,
                              'right': 0,
                              'bottom': 0,
                              'left': 0,
                            },
                          },
                          'separator': <String, dynamic>{
                            'id': 'n-2r8x6g8a',
                            'type': 'Divider',
                            'variant': 'Solid',
                            'props': <String, dynamic>{
                              'color': 'token:c-border',
                              'thickness': 1,
                            },
                          },
                          'children': <Map<String, dynamic>>[
                            <String, dynamic>{
                              'id': 'n-326jwxp8',
                              'type': 'Row',
                              'props': <String, dynamic>{
                                'mainAxisAlignment': 'spaceBetween',
                                'crossAxisAlignment': 'center',
                              },
                              'layout': {
                                'padding': {
                                  'top': 14,
                                  'right': 0,
                                  'bottom': 14,
                                  'left': 0,
                                },
                              },
                              'children': <Map<String, dynamic>>[
                                <String, dynamic>{
                                  'id': 'n-3zvqy02k',
                                  'type': 'Column',
                                  'props': <String, dynamic>{
                                    'gap': 2,
                                    'crossAxisAlignment': 'start',
                                  },
                                  'layout': {'flex': 1},
                                  'children': <Map<String, dynamic>>[
                                    <String, dynamic>{
                                      'id': 'n-hmp6v3a0',
                                      'type': 'Text',
                                      'props': <String, dynamic>{
                                        'text': 'Price Alerts',
                                        'textStyle': 'token:body',
                                        'weight': 'w400',
                                        'size': 15,
                                        'color': 'token:ink',
                                      },
                                    },
                                    <String, dynamic>{
                                      'id': 'n-jyubppkq',
                                      'type': 'Text',
                                      'props': <String, dynamic>{
                                        'text':
                                            'Get notified on big price moves',
                                        'textStyle': 'token:caption',
                                        'size': 12,
                                        'weight': 'w500',
                                        'color': 'token:inkMuted',
                                      },
                                    },
                                  ],
                                },
                                <String, dynamic>{
                                  'id': 'n-j1vq1y81',
                                  'type': 'Switch',
                                  'props': <String, dynamic>{
                                    'color': 'token:brandIndigo',
                                    'value': exprGet(_ctx, <String>[
                                      'state',
                                      'notifyPriceAlerts',
                                    ]),
                                  },
                                  'bindValue': 'notifyPriceAlerts',
                                },
                              ],
                            },
                            <String, dynamic>{
                              'id': 'n-oazuv5w7',
                              'type': 'Row',
                              'props': <String, dynamic>{
                                'mainAxisAlignment': 'spaceBetween',
                                'crossAxisAlignment': 'center',
                              },
                              'layout': {
                                'padding': {
                                  'top': 14,
                                  'right': 0,
                                  'bottom': 14,
                                  'left': 0,
                                },
                              },
                              'children': <Map<String, dynamic>>[
                                <String, dynamic>{
                                  'id': 'n-fw8s5cja',
                                  'type': 'Column',
                                  'props': <String, dynamic>{
                                    'gap': 2,
                                    'crossAxisAlignment': 'start',
                                  },
                                  'layout': {'flex': 1},
                                  'children': <Map<String, dynamic>>[
                                    <String, dynamic>{
                                      'id': 'n-3hver0e6',
                                      'type': 'Text',
                                      'props': <String, dynamic>{
                                        'text': 'Transaction Updates',
                                        'textStyle': 'token:body',
                                        'weight': 'w400',
                                        'size': 15,
                                        'color': 'token:ink',
                                      },
                                    },
                                    <String, dynamic>{
                                      'id': 'n-buwdfr9l',
                                      'type': 'Text',
                                      'props': <String, dynamic>{
                                        'text':
                                            'Buy, sell and transfer confirmations',
                                        'textStyle': 'token:caption',
                                        'size': 12,
                                        'weight': 'w500',
                                        'color': 'token:inkMuted',
                                      },
                                    },
                                  ],
                                },
                                <String, dynamic>{
                                  'id': 'n-uea9f38a',
                                  'type': 'Switch',
                                  'props': <String, dynamic>{
                                    'color': 'token:brandIndigo',
                                    'value': exprGet(_ctx, <String>[
                                      'state',
                                      'notifyTransactions',
                                    ]),
                                  },
                                  'bindValue': 'notifyTransactions',
                                },
                              ],
                            },
                            <String, dynamic>{
                              'id': 'n-6aormx60',
                              'type': 'Row',
                              'props': <String, dynamic>{
                                'mainAxisAlignment': 'spaceBetween',
                                'crossAxisAlignment': 'center',
                              },
                              'layout': {
                                'padding': {
                                  'top': 14,
                                  'right': 0,
                                  'bottom': 14,
                                  'left': 0,
                                },
                              },
                              'children': <Map<String, dynamic>>[
                                <String, dynamic>{
                                  'id': 'n-1br98vft',
                                  'type': 'Column',
                                  'props': <String, dynamic>{
                                    'gap': 2,
                                    'crossAxisAlignment': 'start',
                                  },
                                  'layout': {'flex': 1},
                                  'children': <Map<String, dynamic>>[
                                    <String, dynamic>{
                                      'id': 'n-z23x8lii',
                                      'type': 'Text',
                                      'props': <String, dynamic>{
                                        'text': 'Promotions & Offers',
                                        'textStyle': 'token:body',
                                        'weight': 'w400',
                                        'size': 15,
                                        'color': 'token:ink',
                                      },
                                    },
                                    <String, dynamic>{
                                      'id': 'n-luhw3zur',
                                      'type': 'Text',
                                      'props': <String, dynamic>{
                                        'text':
                                            'Rewards, referral bonuses and news',
                                        'textStyle': 'token:caption',
                                        'size': 12,
                                        'weight': 'w500',
                                        'color': 'token:inkMuted',
                                      },
                                    },
                                  ],
                                },
                                <String, dynamic>{
                                  'id': 'n-s3646l2r',
                                  'type': 'Switch',
                                  'props': <String, dynamic>{
                                    'color': 'token:brandIndigo',
                                    'value': exprGet(_ctx, <String>[
                                      'state',
                                      'notifyPromotions',
                                    ]),
                                  },
                                  'bindValue': 'notifyPromotions',
                                },
                              ],
                            },
                          ],
                        },
                      ],
                    }),
                    onInput: _handleInput,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
