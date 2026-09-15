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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _handleEvent(String id, String event, [Map<String, dynamic>? _item]) {
    final state = ref.read(appStateProvider);
    final appState = ref.read(appStateProvider.notifier);
    Map<String, dynamic> _ctx = <String, dynamic>{'state': state, ...?_item};
    switch ('$id::$event') {
      case 'n-82wltg18::onTap':
        context.push('/notifications');
        break;
      case 'n-ex51fy3i::onTap':
        appState.hideBalance = (!state.hideBalance);
        break;
      case 'n-2ar3lwc2::onTap':
        context.go('/market');
        break;
      case 'n-9t8jct39::onTap':
        appState.selectedCoin = exprIndex(state.trendingCoins, 0);
        _ctx['state'] = ref.read(appStateProvider);
        context.push('/buy');
        break;
      case 'n-e0br4gaw::onTap':
        context.push('/referral');
        break;
      case 'n-2gxujsh7::onTap':
        context.push('/spin');
        break;
      case 'n-uq39ziku::onTap':
        context.go('/market');
        break;
      case 'n-imc8nxca::onTap':
        appState.selectedCoin = exprGet(_ctx, <String>['coin']);
        _ctx['state'] = ref.read(appStateProvider);
        context.push('/coin-detail');
        break;
      case 'n-yvpafsws::qa:0':
        appState.selectedCoin = exprIndex(state.trendingCoins, 0);
        _ctx['state'] = ref.read(appStateProvider);
        context.push('/buy');
        break;
      case 'n-yvpafsws::qa:1':
        appState.selectedCoin = ((exprLen(state.portfolioHoldings) > 0)
            ? exprIndex(state.portfolioHoldings, 0)
            : exprIndex(state.trendingCoins, 0));
        _ctx['state'] = ref.read(appStateProvider);
        context.push('/send');
        break;
      case 'n-yvpafsws::qa:2':
        appState.selectedCoin = exprIndex(state.trendingCoins, 0);
        _ctx['state'] = ref.read(appStateProvider);
        context.push('/receive');
        break;
      case 'n-yvpafsws::qa:3':
        context.push('/deposit');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final Map<String, dynamic> _ctx = <String, dynamic>{'state': state};
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
                      'id': 's-home__root',
                      'type': 'Column',
                      'props': <String, dynamic>{
                        'crossAxisAlignment': 'stretch',
                        'gap': 16,
                        'scrollable': true,
                      },
                      'children': <Map<String, dynamic>>[
                        <String, dynamic>{
                          'id': 'n-dpjxy0uv',
                          'type': 'Row',
                          'props': <String, dynamic>{
                            'mainAxisAlignment': 'spaceBetween',
                            'crossAxisAlignment': 'center',
                          },
                          'children': <Map<String, dynamic>>[
                            <String, dynamic>{
                              'id': 'n-7bljyj1k',
                              'type': 'Row',
                              'props': <String, dynamic>{'gap': 12},
                              'layout': {'width': 'hug'},
                              'children': <Map<String, dynamic>>[
                                <String, dynamic>{
                                  'id': 'n-1c67cbfd',
                                  'type': 'Avatar',
                                  'variant': 'Medium',
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
                                  },
                                },
                                <String, dynamic>{
                                  'id': 'n-musiiwh5',
                                  'type': 'Column',
                                  'props': <String, dynamic>{
                                    'gap': 2,
                                    'crossAxisAlignment': 'start',
                                  },
                                  'children': <Map<String, dynamic>>[
                                    <String, dynamic>{
                                      'id': 'n-kv6szhcx',
                                      'type': 'Text',
                                      'props': <String, dynamic>{
                                        'text': 'Welcome back',
                                        'textStyle': 'token:caption',
                                        'size': 12,
                                        'weight': 'w500',
                                        'color': 'token:inkMuted',
                                      },
                                    },
                                    <String, dynamic>{
                                      'id': 'n-7o1a8adr',
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
                                        'textStyle': 'token:heading2',
                                        'size': 18,
                                        'weight': 'w600',
                                        'color': 'token:ink',
                                      },
                                    },
                                  ],
                                },
                              ],
                            },
                            <String, dynamic>{
                              'id': 'n-82wltg18',
                              'type': 'Container',
                              'props': <String, dynamic>{
                                'color': '#00000000',
                                'padding': {
                                  'top': 10,
                                  'right': 10,
                                  'bottom': 10,
                                  'left': 10,
                                },
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
                              'children': <Map<String, dynamic>>[
                                <String, dynamic>{
                                  'id': 'n-7zg6xkx8',
                                  'type': 'Icon',
                                  'props': <String, dynamic>{
                                    'icon': 'notifications',
                                    'size': 22,
                                    'color': 'token:ink',
                                  },
                                },
                              ],
                            },
                          ],
                        },
                        <String, dynamic>{
                          'id': 'n-qe6ug6k8',
                          'type': 'Container',
                          'props': <String, dynamic>{
                            'color': 'gradient:heroIndigoViolet',
                            'radius': 24,
                            'padding': {
                              'top': 24,
                              'right': 24,
                              'bottom': 24,
                              'left': 24,
                            },
                            'elevation': 8,
                          },
                          'layout': {
                            'width': 'fill',
                            'margin': {
                              'top': 4,
                              'right': 0,
                              'bottom': 0,
                              'left': 0,
                            },
                          },
                          'children': <Map<String, dynamic>>[
                            <String, dynamic>{
                              'id': 'n-u1ofdgub',
                              'type': 'Column',
                              'props': <String, dynamic>{
                                'gap': 8,
                                'crossAxisAlignment': 'start',
                              },
                              'children': <Map<String, dynamic>>[
                                <String, dynamic>{
                                  'id': 'n-j86gr4mh',
                                  'type': 'Row',
                                  'props': <String, dynamic>{
                                    'mainAxisAlignment': 'spaceBetween',
                                  },
                                  'layout': {'width': 'fill'},
                                  'children': <Map<String, dynamic>>[
                                    <String, dynamic>{
                                      'id': 'n-oxu1v1lz',
                                      'type': 'Text',
                                      'props': <String, dynamic>{
                                        'text': 'Total Balance',
                                        'color': '#FFFFFFB3',
                                        'size': 13,
                                      },
                                    },
                                    <String, dynamic>{
                                      'id': 'n-ex51fy3i',
                                      'type': 'Container',
                                      'props': <String, dynamic>{
                                        'color': '#00000000',
                                        'padding': {
                                          'top': 8,
                                          'right': 8,
                                          'bottom': 8,
                                          'left': 8,
                                        },
                                      },
                                      'events': {
                                        'onTap': [
                                          {
                                            'kind': 'setState',
                                            'target': 'hideBalance',
                                            'valueExpr': '!state.hideBalance',
                                          },
                                        ],
                                      },
                                      'children': <Map<String, dynamic>>[
                                        <String, dynamic>{
                                          'id': 'n-oaw33qqk',
                                          'type': 'Icon',
                                          'props': <String, dynamic>{
                                            'icon':
                                                (exprTruthy(
                                                  exprGet(_ctx, <String>[
                                                    'state',
                                                    'hideBalance',
                                                  ]),
                                                )
                                                ? 'eye_off'
                                                : 'eye'),
                                            'size': 16,
                                            'color': '#FFFFFF',
                                          },
                                        },
                                      ],
                                    },
                                  ],
                                },
                                <String, dynamic>{
                                  'id': 'n-3jejs8t6',
                                  'type': 'AmountDisplay',
                                  'variant': 'Hero',
                                  'props': <String, dynamic>{
                                    'value': exprFormatNumber(
                                      exprGet(_ctx, <String>[
                                        'state',
                                        'portfolioValue',
                                      ]),
                                      2,
                                    ),
                                    'currency': '\$',
                                    'align': 'left',
                                    'color': '#FFFFFF',
                                    'size': 36,
                                    'hideable': true,
                                    'hidden': exprGet(_ctx, <String>[
                                      'state',
                                      'hideBalance',
                                    ]),
                                  },
                                },
                                <String, dynamic>{
                                  'id': 'n-g4cbwpda',
                                  'type': 'Row',
                                  'props': <String, dynamic>{'gap': 6},
                                  'layout': {
                                    'width': 'hug',
                                    'margin': {
                                      'top': 4,
                                      'right': 0,
                                      'bottom': 0,
                                      'left': 0,
                                    },
                                  },
                                  'children': <Map<String, dynamic>>[
                                    <String, dynamic>{
                                      'id': 'n-lqbbokbn',
                                      'type': 'Icon',
                                      'props': <String, dynamic>{
                                        'icon': 'arrow_up_right',
                                        'size': 14,
                                        'color': '#FFFFFF',
                                      },
                                    },
                                    <String, dynamic>{
                                      'id': 'n-clhcpg3l',
                                      'type': 'Text',
                                      'props': <String, dynamic>{
                                        'text':
                                            '+${exprGet(_ctx, <String>['state', 'portfolioChangePct'])}% today',
                                        'color': '#FFFFFF',
                                        'size': 13,
                                        'weight': 'w600',
                                      },
                                    },
                                  ],
                                },
                              ],
                            },
                          ],
                        },
                        <String, dynamic>{
                          'id': 'n-yvpafsws',
                          'type': 'QuickActions',
                          'variant': 'Classic',
                          'props': <String, dynamic>{
                            'primaryColor': 'token:brandIndigo',
                            'items': [
                              {
                                'id': 'buy',
                                'icon': 'add',
                                'label': 'Buy',
                                'onTap': [
                                  {
                                    'kind': 'setState',
                                    'target': 'selectedCoin',
                                    'valueExpr': 'state.trendingCoins[0]',
                                  },
                                  {
                                    'kind': 'navigate',
                                    'routeId': 'r-buy',
                                    'mode': 'push',
                                  },
                                ],
                              },
                              {
                                'id': 'send',
                                'icon': 'send',
                                'label': 'Send',
                                'onTap': [
                                  {
                                    'kind': 'setState',
                                    'target': 'selectedCoin',
                                    'valueExpr':
                                        'len(state.portfolioHoldings) > 0 ? state.portfolioHoldings[0] : state.trendingCoins[0]',
                                  },
                                  {
                                    'kind': 'navigate',
                                    'routeId': 'r-send',
                                    'mode': 'push',
                                  },
                                ],
                              },
                              {
                                'id': 'receive',
                                'icon': 'receive',
                                'label': 'Receive',
                                'onTap': [
                                  {
                                    'kind': 'setState',
                                    'target': 'selectedCoin',
                                    'valueExpr': 'state.trendingCoins[0]',
                                  },
                                  {
                                    'kind': 'navigate',
                                    'routeId': 'r-receive',
                                    'mode': 'push',
                                  },
                                ],
                              },
                              {
                                'id': 'deposit',
                                'icon': 'topup',
                                'label': 'Deposit',
                                'onTap': [
                                  {
                                    'kind': 'navigate',
                                    'routeId': 'r-deposit',
                                    'mode': 'push',
                                  },
                                ],
                              },
                            ],
                          },
                          'layout': {
                            'margin': {
                              'top': 8,
                              'right': 0,
                              'bottom': 0,
                              'left': 0,
                            },
                          },
                        },
                        <String, dynamic>{
                          'id': 'n-kik1mlxo',
                          'type': 'PageView',
                          'props': <String, dynamic>{
                            'height': 150,
                            'autoSlide': true,
                            'intervalMs': 4500,
                            'loop': true,
                            'showDots': true,
                            'activeDotColor': 'token:brandIndigo',
                            'dotColor': 'token:hairline',
                            'dotsPosition': 'below',
                          },
                          'layout': {
                            'width': 'fill',
                            'margin': {
                              'top': 16,
                              'right': 0,
                              'bottom': 0,
                              'left': 0,
                            },
                          },
                          'children': <Map<String, dynamic>>[
                            <String, dynamic>{
                              'id': 'n-2ar3lwc2',
                              'type': 'Container',
                              'props': <String, dynamic>{
                                'color': 'gradient:heroIndigoViolet',
                                'radius': 20,
                                'padding': {
                                  'top': 18,
                                  'right': 18,
                                  'bottom': 18,
                                  'left': 18,
                                },
                              },
                              'layout': {
                                'width': 'fill',
                                'height': 'fill',
                                'margin': {'right': 4, 'left': 0},
                              },
                              'events': {
                                'onTap': [
                                  {
                                    'kind': 'navigate',
                                    'routeId': 'r-market',
                                    'mode': 'replace',
                                  },
                                ],
                              },
                              'children': <Map<String, dynamic>>[
                                <String, dynamic>{
                                  'id': 'n-zw7bjs6j',
                                  'type': 'Row',
                                  'props': <String, dynamic>{
                                    'mainAxisAlignment': 'spaceBetween',
                                    'crossAxisAlignment': 'start',
                                  },
                                  'layout': {'height': 'fill'},
                                  'children': <Map<String, dynamic>>[
                                    <String, dynamic>{
                                      'id': 'n-0tx0wd4o',
                                      'type': 'Column',
                                      'props': <String, dynamic>{
                                        'gap': 6,
                                        'crossAxisAlignment': 'start',
                                      },
                                      'layout': {'flex': 1},
                                      'children': <Map<String, dynamic>>[
                                        <String, dynamic>{
                                          'id': 'n-ozqzgiuy',
                                          'type': 'Text',
                                          'props': <String, dynamic>{
                                            'text': 'BEGINNER GUIDE',
                                            'size': 11,
                                            'weight': 'w700',
                                            'color': '#FFFFFFB3',
                                          },
                                        },
                                        <String, dynamic>{
                                          'id': 'n-adaxkmx6',
                                          'type': 'Text',
                                          'props': <String, dynamic>{
                                            'text': 'Learn how to get started',
                                            'size': 17,
                                            'weight': 'w700',
                                            'color': '#FFFFFF',
                                          },
                                        },
                                      ],
                                    },
                                    <String, dynamic>{
                                      'id': 'n-gvv9rhwa',
                                      'type': 'Icon',
                                      'props': <String, dynamic>{
                                        'icon': 'help',
                                        'size': 28,
                                        'color': '#FFFFFF',
                                      },
                                    },
                                  ],
                                },
                              ],
                            },
                            <String, dynamic>{
                              'id': 'n-9t8jct39',
                              'type': 'Container',
                              'props': <String, dynamic>{
                                'color': 'token:brandIndigo',
                                'radius': 20,
                                'padding': {
                                  'top': 18,
                                  'right': 18,
                                  'bottom': 18,
                                  'left': 18,
                                },
                              },
                              'layout': {
                                'width': 'fill',
                                'height': 'fill',
                                'margin': {'right': 4, 'left': 0},
                              },
                              'events': {
                                'onTap': [
                                  {
                                    'kind': 'setState',
                                    'target': 'selectedCoin',
                                    'valueExpr': 'state.trendingCoins[0]',
                                  },
                                  {
                                    'kind': 'navigate',
                                    'routeId': 'r-buy',
                                    'mode': 'push',
                                  },
                                ],
                              },
                              'children': <Map<String, dynamic>>[
                                <String, dynamic>{
                                  'id': 'n-frfwx8ay',
                                  'type': 'Row',
                                  'props': <String, dynamic>{
                                    'mainAxisAlignment': 'spaceBetween',
                                    'crossAxisAlignment': 'start',
                                  },
                                  'layout': {'height': 'fill'},
                                  'children': <Map<String, dynamic>>[
                                    <String, dynamic>{
                                      'id': 'n-o7mqsdbp',
                                      'type': 'Column',
                                      'props': <String, dynamic>{
                                        'gap': 6,
                                        'crossAxisAlignment': 'start',
                                      },
                                      'layout': {'flex': 1},
                                      'children': <Map<String, dynamic>>[
                                        <String, dynamic>{
                                          'id': 'n-lqgsiubk',
                                          'type': 'Text',
                                          'props': <String, dynamic>{
                                            'text': 'GET STARTED',
                                            'size': 11,
                                            'weight': 'w700',
                                            'color': '#FFFFFFB3',
                                          },
                                        },
                                        <String, dynamic>{
                                          'id': 'n-ty88j83w',
                                          'type': 'Text',
                                          'props': <String, dynamic>{
                                            'text':
                                                'Make your first investment today',
                                            'size': 17,
                                            'weight': 'w700',
                                            'color': '#FFFFFF',
                                          },
                                        },
                                      ],
                                    },
                                    <String, dynamic>{
                                      'id': 'n-1y5fhbb2',
                                      'type': 'Icon',
                                      'props': <String, dynamic>{
                                        'icon': 'chart',
                                        'size': 28,
                                        'color': '#FFFFFF',
                                      },
                                    },
                                  ],
                                },
                              ],
                            },
                            <String, dynamic>{
                              'id': 'n-e0br4gaw',
                              'type': 'Container',
                              'props': <String, dynamic>{
                                'color': 'token:accentAmber',
                                'radius': 20,
                                'padding': {
                                  'top': 18,
                                  'right': 18,
                                  'bottom': 18,
                                  'left': 18,
                                },
                              },
                              'layout': {
                                'width': 'fill',
                                'height': 'fill',
                                'margin': {'right': 4, 'left': 0},
                              },
                              'events': {
                                'onTap': [
                                  {
                                    'kind': 'navigate',
                                    'routeId': 'r-referral',
                                    'mode': 'push',
                                  },
                                ],
                              },
                              'children': <Map<String, dynamic>>[
                                <String, dynamic>{
                                  'id': 'n-kj3lwsja',
                                  'type': 'Row',
                                  'props': <String, dynamic>{
                                    'mainAxisAlignment': 'spaceBetween',
                                    'crossAxisAlignment': 'start',
                                  },
                                  'layout': {'height': 'fill'},
                                  'children': <Map<String, dynamic>>[
                                    <String, dynamic>{
                                      'id': 'n-1ce9iexa',
                                      'type': 'Column',
                                      'props': <String, dynamic>{
                                        'gap': 6,
                                        'crossAxisAlignment': 'start',
                                      },
                                      'layout': {'flex': 1},
                                      'children': <Map<String, dynamic>>[
                                        <String, dynamic>{
                                          'id': 'n-gtirwou3',
                                          'type': 'Text',
                                          'props': <String, dynamic>{
                                            'text': 'REFER & EARN',
                                            'size': 11,
                                            'weight': 'w700',
                                            'color': '#FFFFFFCC',
                                          },
                                        },
                                        <String, dynamic>{
                                          'id': 'n-bwc42urw',
                                          'type': 'Text',
                                          'props': <String, dynamic>{
                                            'text':
                                                'Refer a friend, win crypto',
                                            'size': 17,
                                            'weight': 'w700',
                                            'color': '#FFFFFF',
                                          },
                                        },
                                      ],
                                    },
                                    <String, dynamic>{
                                      'id': 'n-o0zoq7er',
                                      'type': 'Icon',
                                      'props': <String, dynamic>{
                                        'icon': 'gift',
                                        'size': 28,
                                        'color': '#FFFFFF',
                                      },
                                    },
                                  ],
                                },
                              ],
                            },
                            <String, dynamic>{
                              'id': 'n-2gxujsh7',
                              'type': 'Container',
                              'props': <String, dynamic>{
                                'color': 'token:accentStrong',
                                'radius': 20,
                                'padding': {
                                  'top': 18,
                                  'right': 18,
                                  'bottom': 18,
                                  'left': 18,
                                },
                              },
                              'layout': {
                                'width': 'fill',
                                'height': 'fill',
                                'margin': {'right': 0, 'left': 0},
                              },
                              'events': {
                                'onTap': [
                                  {
                                    'kind': 'navigate',
                                    'routeId': 'r-spin-wheel',
                                    'mode': 'push',
                                  },
                                ],
                              },
                              'children': <Map<String, dynamic>>[
                                <String, dynamic>{
                                  'id': 'n-53i6dtns',
                                  'type': 'Row',
                                  'props': <String, dynamic>{
                                    'mainAxisAlignment': 'spaceBetween',
                                    'crossAxisAlignment': 'start',
                                  },
                                  'layout': {'height': 'fill'},
                                  'children': <Map<String, dynamic>>[
                                    <String, dynamic>{
                                      'id': 'n-tpi8vlzj',
                                      'type': 'Column',
                                      'props': <String, dynamic>{
                                        'gap': 6,
                                        'crossAxisAlignment': 'start',
                                      },
                                      'layout': {'flex': 1},
                                      'children': <Map<String, dynamic>>[
                                        <String, dynamic>{
                                          'id': 'n-tzfui07x',
                                          'type': 'Text',
                                          'props': <String, dynamic>{
                                            'text': 'SPIN & WIN',
                                            'size': 11,
                                            'weight': 'w700',
                                            'color': '#FFFFFFCC',
                                          },
                                        },
                                        <String, dynamic>{
                                          'id': 'n-o46xth0e',
                                          'type': 'Text',
                                          'props': <String, dynamic>{
                                            'text':
                                                'Spin the wheel for free tokens',
                                            'size': 17,
                                            'weight': 'w700',
                                            'color': '#FFFFFF',
                                          },
                                        },
                                      ],
                                    },
                                    <String, dynamic>{
                                      'id': 'n-907a4xvi',
                                      'type': 'Icon',
                                      'props': <String, dynamic>{
                                        'icon': 'star_filled',
                                        'size': 28,
                                        'color': '#FFFFFF',
                                      },
                                    },
                                  ],
                                },
                              ],
                            },
                          ],
                        },
                        <String, dynamic>{
                          'id': 'n-2w3a7yc7',
                          'type': 'Row',
                          'props': <String, dynamic>{
                            'mainAxisAlignment': 'spaceBetween',
                            'crossAxisAlignment': 'center',
                          },
                          'layout': {
                            'margin': {
                              'top': 16,
                              'right': 0,
                              'bottom': 0,
                              'left': 0,
                            },
                          },
                          'children': <Map<String, dynamic>>[
                            <String, dynamic>{
                              'id': 'n-a3d0p2sh',
                              'type': 'Text',
                              'props': <String, dynamic>{
                                'text': 'Trending Coins',
                                'textStyle': 'token:heading2',
                                'size': 18,
                                'weight': 'w600',
                                'color': 'token:ink',
                              },
                            },
                            <String, dynamic>{
                              'id': 'n-uq39ziku',
                              'type': 'Text',
                              'props': <String, dynamic>{
                                'text': 'See all',
                                'textStyle': 'token:bodyMuted',
                                'color': 'token:inkMuted',
                                'weight': 'w400',
                                'size': 14,
                              },
                              'events': {
                                'onTap': [
                                  {
                                    'kind': 'navigate',
                                    'routeId': 'r-market',
                                    'mode': 'replace',
                                  },
                                ],
                              },
                            },
                          ],
                        },
                        <String, dynamic>{
                          'id': 'n-fwiva9xr',
                          'type': 'Column',
                          'props': <String, dynamic>{'gap': 4},
                          'layout': {
                            'margin': {
                              'top': 16,
                              'right': 0,
                              'bottom': 0,
                              'left': 0,
                            },
                          },
                          'separator': <String, dynamic>{
                            'id': 'n-custg0w6',
                            'type': 'Divider',
                            'variant': 'Solid',
                            'props': <String, dynamic>{
                              'color': 'token:c-border',
                              'thickness': 1,
                            },
                          },
                          'children': <Map<String, dynamic>>[
                            ...List<Map<String, dynamic>>.generate(
                              exprLen(
                                exprGet(_ctx, <String>[
                                  'state',
                                  'trendingCoins',
                                ]),
                              ),
                              (int _i) => exprWithItem(
                                _ctx,
                                'coin',
                                exprElemAt(
                                  exprGet(_ctx, <String>[
                                    'state',
                                    'trendingCoins',
                                  ]),
                                  _i,
                                ),
                                (
                                  Map<String, dynamic> _ctx,
                                ) => <String, dynamic>{
                                  'id': 'n-imc8nxca',
                                  'type': 'Row',
                                  'props': <String, dynamic>{
                                    'mainAxisAlignment': 'spaceBetween',
                                    'crossAxisAlignment': 'center',
                                  },
                                  'layout': {
                                    'padding': {
                                      'top': 10,
                                      'right': 0,
                                      'bottom': 10,
                                      'left': 0,
                                    },
                                  },
                                  'events': {
                                    'onTap': [
                                      {
                                        'kind': 'setState',
                                        'target': 'selectedCoin',
                                        'valueExpr': 'coin',
                                      },
                                      {
                                        'kind': 'navigate',
                                        'routeId': 'r-coin-detail',
                                        'mode': 'push',
                                      },
                                    ],
                                  },
                                  '_itemCtx': <String, dynamic>{
                                    'coin': exprGet(_ctx, <String>['coin']),
                                  },
                                  'children': <Map<String, dynamic>>[
                                    <String, dynamic>{
                                      'id': 'n-jypny384',
                                      'type': 'Row',
                                      'props': <String, dynamic>{'gap': 12},
                                      'layout': {'width': 'hug'},
                                      'children': <Map<String, dynamic>>[
                                        <String, dynamic>{
                                          'id': 'n-sqi70t4h',
                                          'type': 'Container',
                                          'props': <String, dynamic>{
                                            'color': exprGet(_ctx, <String>[
                                              'coin',
                                              'color',
                                            ]),
                                            'radius': 999,
                                            'padding': {
                                              'top': 8,
                                              'right': 8,
                                              'bottom': 8,
                                              'left': 8,
                                            },
                                          },
                                          'layout': {'width': 40, 'height': 40},
                                          'children': <Map<String, dynamic>>[
                                            <String, dynamic>{
                                              'id': 'n-2dlqmrom',
                                              'type': 'Image',
                                              'props': <String, dynamic>{
                                                'src': exprGet(_ctx, <String>[
                                                  'coin',
                                                  'icon',
                                                ]),
                                                'fit': 'contain',
                                              },
                                            },
                                          ],
                                        },
                                        <String, dynamic>{
                                          'id': 'n-rkkxv2m5',
                                          'type': 'Column',
                                          'props': <String, dynamic>{
                                            'gap': 2,
                                            'crossAxisAlignment': 'start',
                                          },
                                          'children': <Map<String, dynamic>>[
                                            <String, dynamic>{
                                              'id': 'n-je48k0a0',
                                              'type': 'Text',
                                              'props': <String, dynamic>{
                                                'text': exprGet(_ctx, <String>[
                                                  'coin',
                                                  'name',
                                                ]),
                                                'textStyle': 'token:body',
                                                'weight': 'w400',
                                                'size': 15,
                                                'color': 'token:ink',
                                              },
                                            },
                                            <String, dynamic>{
                                              'id': 'n-sr70dmzg',
                                              'type': 'Text',
                                              'props': <String, dynamic>{
                                                'text': exprGet(_ctx, <String>[
                                                  'coin',
                                                  'symbol',
                                                ]),
                                                'textStyle': 'token:caption',
                                                'size': 12,
                                                'weight': 'w500',
                                                'color': 'token:inkMuted',
                                              },
                                            },
                                          ],
                                        },
                                      ],
                                    },
                                    <String, dynamic>{
                                      'id': 'n-v4k34i26',
                                      'type': 'Column',
                                      'props': <String, dynamic>{
                                        'gap': 2,
                                        'crossAxisAlignment': 'end',
                                      },
                                      'children': <Map<String, dynamic>>[
                                        <String, dynamic>{
                                          'id': 'n-l7j7krey',
                                          'type': 'AmountDisplay',
                                          'variant': 'Inline',
                                          'props': <String, dynamic>{
                                            'value': exprFormatNumber(
                                              exprGet(_ctx, <String>[
                                                'coin',
                                                'price',
                                              ]),
                                              2,
                                            ),
                                            'currency': '\$',
                                            'align': 'right',
                                            'color': 'token:ink',
                                            'size': 15,
                                          },
                                        },
                                        <String, dynamic>{
                                          'id': 'n-5b0hqmrz',
                                          'type': 'Row',
                                          'props': <String, dynamic>{
                                            'gap': 2,
                                            'crossAxisAlignment': 'center',
                                          },
                                          'children': <Map<String, dynamic>>[
                                            <String, dynamic>{
                                              'id': 'n-55qtn0d9',
                                              'type': 'Icon',
                                              'props': <String, dynamic>{
                                                'icon':
                                                    (exprTruthy(
                                                      exprGet(_ctx, <String>[
                                                        'coin',
                                                        'up',
                                                      ]),
                                                    )
                                                    ? 'arrow_up_right'
                                                    : 'arrow_down_left'),
                                                'size': 14,
                                                'color':
                                                    (exprTruthy(
                                                      exprGet(_ctx, <String>[
                                                        'coin',
                                                        'up',
                                                      ]),
                                                    )
                                                    ? 'token:gainGreen'
                                                    : 'token:lossRed'),
                                              },
                                            },
                                            <String, dynamic>{
                                              'id': 'n-npto9tbg',
                                              'type': 'Text',
                                              'props': <String, dynamic>{
                                                'text':
                                                    (exprTruthy(
                                                      exprGet(_ctx, <String>[
                                                        'coin',
                                                        'up',
                                                      ]),
                                                    )
                                                    ? '+${exprGet(_ctx, <String>['coin', 'change'])}%'
                                                    : '${exprGet(_ctx, <String>['coin', 'change'])}%'),
                                                'color':
                                                    (exprTruthy(
                                                      exprGet(_ctx, <String>[
                                                        'coin',
                                                        'up',
                                                      ]),
                                                    )
                                                    ? 'token:gainGreen'
                                                    : 'token:lossRed'),
                                                'size': 12,
                                                'weight': 'w600',
                                              },
                                            },
                                          ],
                                        },
                                      ],
                                    },
                                  ],
                                },
                              ),
                            ),
                          ],
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
