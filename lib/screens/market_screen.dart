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

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _handleEvent(String id, String event, [Map<String, dynamic>? _item]) {
    final appState = ref.read(appStateProvider.notifier);
    Map<String, dynamic> _ctx = <String, dynamic>{
      'state': ref.read(appStateProvider),
      ...?_item,
    };
    switch ('$id::$event') {
      case 'n-ckc4qbc2::onTap':
        context.push('/search');
        break;
      case 'n-m31nh48r::onTap':
        appState.selectedCoin = exprGet(_ctx, <String>['coin']);
        _ctx['state'] = ref.read(appStateProvider);
        context.push('/coin-detail');
        break;
      default:
        break;
    }
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
        backgroundColor: AppTheme.background,
        body: SafeArea(
          top: true,
          bottom: false,
          child: ScreenEntrance(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: StateScope(
                state: ref.watch(appStateProvider),
                child: Builder(
                  builder: (context) => buildNode(
                    context,
                    NodeModel.fromJson(<String, dynamic>{
                      'id': 's-market__root',
                      'type': 'Column',
                      'props': <String, dynamic>{
                        'crossAxisAlignment': 'stretch',
                        'gap': 16,
                        'scrollable': true,
                      },
                      'children': <Map<String, dynamic>>[
                        <String, dynamic>{
                          'id': 'n-qgm6ie7y',
                          'type': 'Row',
                          'props': <String, dynamic>{
                            'mainAxisAlignment': 'spaceBetween',
                            'crossAxisAlignment': 'center',
                          },
                          'children': <Map<String, dynamic>>[
                            <String, dynamic>{
                              'id': 'n-wgko8san',
                              'type': 'Text',
                              'props': <String, dynamic>{
                                'text': 'Market',
                                'textStyle': 'token:display',
                                'size': 30,
                                'weight': 'w700',
                                'color': 'token:ink',
                              },
                            },
                            <String, dynamic>{
                              'id': 'n-ckc4qbc2',
                              'type': 'Icon',
                              'props': <String, dynamic>{
                                'icon': 'search',
                                'size': 24,
                                'color': 'token:ink',
                              },
                              'events': {
                                'onTap': [
                                  {
                                    'kind': 'navigate',
                                    'routeId': 'r-search',
                                    'mode': 'push',
                                  },
                                ],
                              },
                            },
                          ],
                        },
                        <String, dynamic>{
                          'id': 'n-sgro02cl',
                          'type': 'SegmentedTabs',
                          'variant': 'Pill',
                          'props': <String, dynamic>{
                            'labels': 'All, Gainers, Losers',
                            'accentColor': 'token:brandIndigo',
                            'selectedTextColor': '#FFFFFF',
                            'textColor': 'token:inkMuted',
                            'trackColor': 'token:surfaceAlt',
                            'value': exprGet(_ctx, <String>[
                              'state',
                              'marketTab',
                            ]),
                          },
                          'bindValue': 'marketTab',
                        },
                        <String, dynamic>{
                          'id': 'n-6175uzzl',
                          'type': 'Row',
                          'props': <String, dynamic>{
                            'mainAxisAlignment': 'spaceBetween',
                            'crossAxisAlignment': 'center',
                          },
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
                              'id': 'n-h5m74jnq',
                              'type': 'Text',
                              'props': <String, dynamic>{
                                'text': 'Coins',
                                'textStyle': 'token:heading2',
                                'size': 18,
                                'weight': 'w600',
                                'color': 'token:ink',
                              },
                            },
                            <String, dynamic>{
                              'id': 'n-b8ohjhgy',
                              'type': 'Text',
                              'props': <String, dynamic>{
                                'text':
                                    '${exprLen(exprGet(_ctx, <String>['state', 'trendingCoins']))} listed',
                                'textStyle': 'token:caption',
                                'size': 12,
                                'weight': 'w500',
                                'color': 'token:inkMuted',
                              },
                            },
                          ],
                        },
                        <String, dynamic>{
                          'id': 'n-u8o3647z',
                          'type': 'Column',
                          'props': <String, dynamic>{'gap': 4},
                          'layout': {
                            'margin': {
                              'top': 4,
                              'right': 0,
                              'bottom': 0,
                              'left': 0,
                            },
                          },
                          'separator': <String, dynamic>{
                            'id': 'n-4qkxqsyz',
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
                                  'id': 'n-m31nh48r',
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
                                  '_visible': exprTruthy(
                                    (((exprNum(
                                                  exprGet(_ctx, <String>[
                                                    'marketTab',
                                                  ]),
                                                ) ==
                                                0) ||
                                            ((exprNum(
                                                      exprGet(_ctx, <String>[
                                                        'marketTab',
                                                      ]),
                                                    ) ==
                                                    1) &&
                                                (exprGet(_ctx, <String>[
                                                      'coin',
                                                      'up',
                                                    ]) ==
                                                    true))) ||
                                        ((exprNum(
                                                  exprGet(_ctx, <String>[
                                                    'marketTab',
                                                  ]),
                                                ) ==
                                                2) &&
                                            (exprGet(_ctx, <String>[
                                                  'coin',
                                                  'up',
                                                ]) ==
                                                false))),
                                  ),
                                  'children': <Map<String, dynamic>>[
                                    <String, dynamic>{
                                      'id': 'n-gdri01o1',
                                      'type': 'Row',
                                      'props': <String, dynamic>{'gap': 12},
                                      'layout': {'width': 'hug'},
                                      'children': <Map<String, dynamic>>[
                                        <String, dynamic>{
                                          'id': 'n-4mdg8xzg',
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
                                              'id': 'n-miigd3k5',
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
                                          'id': 'n-0hctd1jq',
                                          'type': 'Column',
                                          'props': <String, dynamic>{
                                            'gap': 2,
                                            'crossAxisAlignment': 'start',
                                          },
                                          'children': <Map<String, dynamic>>[
                                            <String, dynamic>{
                                              'id': 'n-cev8vbmx',
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
                                              'id': 'n-pfvmov7f',
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
                                      'id': 'n-c8lambz6',
                                      'type': 'Column',
                                      'props': <String, dynamic>{
                                        'gap': 2,
                                        'crossAxisAlignment': 'end',
                                      },
                                      'children': <Map<String, dynamic>>[
                                        <String, dynamic>{
                                          'id': 'n-y34hgke7',
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
                                          'id': 'n-8q6k8s35',
                                          'type': 'Row',
                                          'props': <String, dynamic>{
                                            'gap': 2,
                                            'crossAxisAlignment': 'center',
                                          },
                                          'children': <Map<String, dynamic>>[
                                            <String, dynamic>{
                                              'id': 'n-a1weq6io',
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
                                              'id': 'n-r9kgjjoz',
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
