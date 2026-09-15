import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../runtime/motion.dart';
import '../runtime/node.dart';
import '../runtime/node_view.dart';
import 'package:go_router/go_router.dart';
import '../runtime/expr_runtime.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_state.dart';
import '../state/state_scope.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
  }

  // ignore: unused_element_parameter
  void _handleEvent(String id, String event, [Map<String, dynamic>? _item]) {
    final appState = ref.read(appStateProvider.notifier);
    switch ('$id::$event') {
      case 'n-cs3ce5ky::onTap':
        context.push('/history');
        break;
      case 'n-a10612ih::onTap':
        context.push('/bank-details');
        break;
      case 'n-p94tgpo5::onTap':
        context.push('/notifications');
        break;
      case 'n-k7iwz13b::onTap':
        context.push('/security');
        break;
      case 'n-38c0eha5::onTap':
        context.push('/help');
        break;
      case 'n-t5hsbxpm::onTap':
        context.push('/terms');
        break;
      case 'n-l4qnkls6::onTap':
        appState.authToken = '';
        appState.currentUser = null;
        context.go('/login');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> _ctx = <String, dynamic>{
      'state': ref.watch(appStateProvider),
    };
    return AppTheme.scope(
      child: Scaffold(
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
                      'id': 's-profile__root',
                      'type': 'Column',
                      'props': <String, dynamic>{
                        'crossAxisAlignment': 'stretch',
                        'gap': 16,
                        'scrollable': true,
                      },
                      'children': <Map<String, dynamic>>[
                        <String, dynamic>{
                          'id': 'n-fg6o7hhw',
                          'type': 'Column',
                          'props': <String, dynamic>{
                            'gap': 12,
                            'crossAxisAlignment': 'center',
                          },
                          'layout': {
                            'padding': {
                              'top': 12,
                              'right': 0,
                              'bottom': 8,
                              'left': 0,
                            },
                          },
                          'children': <Map<String, dynamic>>[
                            <String, dynamic>{
                              'id': 'n-a1efdmi4',
                              'type': 'Avatar',
                              'variant': 'Large',
                              'props': <String, dynamic>{
                                'initials':
                                    (exprTruthy(
                                      (exprGet(_ctx, <String>[
                                            'state',
                                            'currentUser',
                                          ]) !=
                                          null),
                                    )
                                    ? exprInitials(
                                        exprGet(_ctx, <String>[
                                          'state',
                                          'currentUser',
                                          'name',
                                        ]),
                                      )
                                    : 'CT'),
                                'backgroundColor': 'token:brandIndigo',
                                'textColor': '#FFFFFF',
                                'size': 72,
                              },
                            },
                            <String, dynamic>{
                              'id': 'n-kl29krbe',
                              'type': 'Text',
                              'props': <String, dynamic>{
                                'text':
                                    (exprTruthy(
                                      (exprGet(_ctx, <String>[
                                            'state',
                                            'currentUser',
                                          ]) !=
                                          null),
                                    )
                                    ? exprGet(_ctx, <String>[
                                        'state',
                                        'currentUser',
                                        'name',
                                      ])
                                    : 'Trader'),
                                'textStyle': 'token:heading1',
                                'align': 'center',
                                'size': 22,
                                'weight': 'w700',
                                'color': 'token:ink',
                              },
                            },
                            <String, dynamic>{
                              'id': 'n-qn5dbvia',
                              'type': 'Text',
                              'props': <String, dynamic>{
                                'text':
                                    (exprTruthy(
                                      (exprGet(_ctx, <String>[
                                            'state',
                                            'currentUser',
                                          ]) !=
                                          null),
                                    )
                                    ? exprGet(_ctx, <String>[
                                        'state',
                                        'currentUser',
                                        'email',
                                      ])
                                    : ''),
                                'textStyle': 'token:bodyMuted',
                                'align': 'center',
                                'size': 14,
                                'weight': 'w400',
                                'color': 'token:inkMuted',
                              },
                            },
                            <String, dynamic>{
                              'id': 'n-ve0jcfr2',
                              'type': 'Text',
                              'props': <String, dynamic>{
                                'text':
                                    (exprTruthy(
                                      (exprGet(_ctx, <String>[
                                            'state',
                                            'currentUser',
                                          ]) !=
                                          null),
                                    )
                                    ? exprGet(_ctx, <String>[
                                        'state',
                                        'currentUser',
                                        'phone',
                                      ])
                                    : ''),
                                'textStyle': 'token:bodyMuted',
                                'align': 'center',
                                'size': 14,
                                'weight': 'w400',
                                'color': 'token:inkMuted',
                              },
                            },
                          ],
                        },
                        <String, dynamic>{
                          'id': 'n-2a0iai3p',
                          'type': 'Column',
                          'props': <String, dynamic>{'gap': 8},
                          'layout': {
                            'margin': {
                              'top': 8,
                              'right': 0,
                              'bottom': 0,
                              'left': 0,
                            },
                          },
                          'children': <Map<String, dynamic>>[
                            <String, dynamic>{
                              'id': 'n-1gfhfyyq',
                              'type': 'Text',
                              'props': <String, dynamic>{
                                'text': 'ACCOUNT',
                                'textStyle': 'token:caption',
                                'letterSpacing': 0.5,
                                'size': 12,
                                'weight': 'w500',
                                'color': 'token:inkMuted',
                              },
                            },
                            <String, dynamic>{
                              'id': 'n-zjd6ozrj',
                              'type': 'Container',
                              'props': <String, dynamic>{
                                'color': 'token:ground',
                                'radius': 16,
                                'padding': {
                                  'top': 4,
                                  'right': 12,
                                  'bottom': 4,
                                  'left': 12,
                                },
                              },
                              'layout': {'width': 'fill'},
                              'children': <Map<String, dynamic>>[
                                <String, dynamic>{
                                  'id': 'n-xx1u0chy',
                                  'type': 'Column',
                                  'props': <String, dynamic>{'gap': 0},
                                  'separator': <String, dynamic>{
                                    'id': 'n-4rro0sdm',
                                    'type': 'Divider',
                                    'variant': 'Solid',
                                    'props': <String, dynamic>{
                                      'color': 'token:c-border',
                                      'thickness': 1,
                                    },
                                  },
                                  'children': <Map<String, dynamic>>[
                                    <String, dynamic>{
                                      'id': 'n-cs3ce5ky',
                                      'type': 'ListRow',
                                      'variant': 'WithIcon',
                                      'props': <String, dynamic>{
                                        'title': 'History',
                                        'leadingIcon': 'history',
                                        'iconColor': 'token:brandIndigo',
                                      },
                                      'layout': {
                                        'margin': {'bottom': 8},
                                      },
                                      'events': {
                                        'onTap': [
                                          {
                                            'kind': 'navigate',
                                            'routeId': 'r-history',
                                            'mode': 'push',
                                          },
                                        ],
                                      },
                                    },
                                    <String, dynamic>{
                                      'id': 'n-a10612ih',
                                      'type': 'ListRow',
                                      'variant': 'WithIcon',
                                      'props': <String, dynamic>{
                                        'title': 'Bank Details',
                                        'leadingIcon': 'bank',
                                        'iconColor': 'token:brandIndigo',
                                      },
                                      'events': {
                                        'onTap': [
                                          {
                                            'kind': 'navigate',
                                            'routeId': 'r-bank-details',
                                            'mode': 'push',
                                          },
                                        ],
                                      },
                                    },
                                  ],
                                },
                              ],
                            },
                          ],
                        },
                        <String, dynamic>{
                          'id': 'n-d2iqow8u',
                          'type': 'Column',
                          'props': <String, dynamic>{'gap': 8},
                          'layout': {
                            'margin': {
                              'top': 4,
                              'right': 0,
                              'bottom': 0,
                              'left': 0,
                            },
                          },
                          'children': <Map<String, dynamic>>[
                            <String, dynamic>{
                              'id': 'n-lof3eyz1',
                              'type': 'Text',
                              'props': <String, dynamic>{
                                'text': 'PREFERENCES',
                                'textStyle': 'token:caption',
                                'letterSpacing': 0.5,
                                'size': 12,
                                'weight': 'w500',
                                'color': 'token:inkMuted',
                              },
                            },
                            <String, dynamic>{
                              'id': 'n-mm5y2meq',
                              'type': 'Container',
                              'props': <String, dynamic>{
                                'color': 'token:ground',
                                'radius': 16,
                                'padding': {
                                  'top': 4,
                                  'right': 12,
                                  'bottom': 4,
                                  'left': 12,
                                },
                                'borderColor': 'token:ground',
                                'borderWidth': 0,
                                'elevation': 0,
                              },
                              'layout': {'width': 'fill'},
                              'children': <Map<String, dynamic>>[
                                <String, dynamic>{
                                  'id': 'n-1l379n40',
                                  'type': 'Column',
                                  'props': <String, dynamic>{'gap': 0},
                                  'separator': <String, dynamic>{
                                    'id': 'n-0qomsdeb',
                                    'type': 'Divider',
                                    'variant': 'Solid',
                                    'props': <String, dynamic>{
                                      'color': 'token:c-border',
                                      'thickness': 1,
                                    },
                                  },
                                  'children': <Map<String, dynamic>>[
                                    <String, dynamic>{
                                      'id': 'n-p94tgpo5',
                                      'type': 'ListRow',
                                      'variant': 'WithIcon',
                                      'props': <String, dynamic>{
                                        'title': 'Notifications',
                                        'leadingIcon': 'notifications',
                                        'iconColor': 'token:brandIndigo',
                                      },
                                      'layout': {
                                        'margin': {'bottom': 8},
                                      },
                                      'events': {
                                        'onTap': [
                                          {
                                            'kind': 'navigate',
                                            'routeId': 'r-notifications',
                                            'mode': 'push',
                                          },
                                        ],
                                      },
                                    },
                                    <String, dynamic>{
                                      'id': 'n-k7iwz13b',
                                      'type': 'ListRow',
                                      'variant': 'WithIcon',
                                      'props': <String, dynamic>{
                                        'title': 'Security',
                                        'leadingIcon': 'security',
                                        'iconColor': 'token:brandIndigo',
                                      },
                                      'events': {
                                        'onTap': [
                                          {
                                            'kind': 'navigate',
                                            'routeId': 'r-security',
                                            'mode': 'push',
                                          },
                                        ],
                                      },
                                    },
                                  ],
                                },
                              ],
                            },
                          ],
                        },
                        <String, dynamic>{
                          'id': 'n-yg41q3d1',
                          'type': 'Column',
                          'props': <String, dynamic>{'gap': 8},
                          'layout': {
                            'margin': {
                              'top': 4,
                              'right': 0,
                              'bottom': 0,
                              'left': 0,
                            },
                          },
                          'children': <Map<String, dynamic>>[
                            <String, dynamic>{
                              'id': 'n-3p1bpuwy',
                              'type': 'Text',
                              'props': <String, dynamic>{
                                'text': 'SUPPORT',
                                'textStyle': 'token:caption',
                                'letterSpacing': 0.5,
                                'size': 12,
                                'weight': 'w500',
                                'color': 'token:inkMuted',
                              },
                            },
                            <String, dynamic>{
                              'id': 'n-vkusq6kd',
                              'type': 'Container',
                              'props': <String, dynamic>{
                                'color': 'token:ground',
                                'radius': 16,
                                'padding': {
                                  'top': 4,
                                  'right': 12,
                                  'bottom': 4,
                                  'left': 12,
                                },
                              },
                              'layout': {'width': 'fill'},
                              'children': <Map<String, dynamic>>[
                                <String, dynamic>{
                                  'id': 'n-ymujq3cf',
                                  'type': 'Column',
                                  'props': <String, dynamic>{'gap': 0},
                                  'separator': <String, dynamic>{
                                    'id': 'n-g5u266tp',
                                    'type': 'Divider',
                                    'variant': 'Solid',
                                    'props': <String, dynamic>{
                                      'color': 'token:c-border',
                                      'thickness': 1,
                                    },
                                  },
                                  'children': <Map<String, dynamic>>[
                                    <String, dynamic>{
                                      'id': 'n-38c0eha5',
                                      'type': 'ListRow',
                                      'variant': 'WithIcon',
                                      'props': <String, dynamic>{
                                        'title': 'Help & Support',
                                        'leadingIcon': 'help',
                                        'iconColor': 'token:brandIndigo',
                                      },
                                      'events': {
                                        'onTap': [
                                          {
                                            'kind': 'navigate',
                                            'routeId': 'r-help-and-support',
                                            'mode': 'push',
                                          },
                                        ],
                                      },
                                    },
                                    <String, dynamic>{
                                      'id': 'n-t5hsbxpm',
                                      'type': 'ListRow',
                                      'variant': 'WithIcon',
                                      'props': <String, dynamic>{
                                        'title': 'Terms and Conditions',
                                        'leadingIcon': 'document',
                                        'iconColor': 'token:brandIndigo',
                                      },
                                      'layout': {
                                        'margin': {'top': 8},
                                      },
                                      'events': {
                                        'onTap': [
                                          {
                                            'kind': 'navigate',
                                            'routeId': 'r-terms',
                                            'mode': 'push',
                                          },
                                        ],
                                      },
                                    },
                                  ],
                                },
                              ],
                            },
                          ],
                        },
                        <String, dynamic>{
                          'id': 'n-l4qnkls6',
                          'type': 'Button',
                          'variant': 'Outlined',
                          'props': <String, dynamic>{
                            'label': 'Log out',
                            'primaryColor': 'token:lossRed',
                            'radius': 999,
                            'showIcon': true,
                            'icon': 'logout',
                          },
                          'layout': {
                            'margin': {
                              'top': 12,
                              'right': 0,
                              'bottom': 8,
                              'left': 0,
                            },
                          },
                          'events': {
                            'onTap': [
                              {
                                'kind': 'setState',
                                'target': 'authToken',
                                'valueExpr': '\'\'',
                              },
                              {
                                'kind': 'setState',
                                'target': 'currentUser',
                                'valueExpr': 'null',
                              },
                              {
                                'kind': 'navigate',
                                'routeId': 'r-login',
                                'mode': 'replace',
                              },
                            ],
                          },
                        },
                      ],
                    }),
                    onEvent: _handleEvent,
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
