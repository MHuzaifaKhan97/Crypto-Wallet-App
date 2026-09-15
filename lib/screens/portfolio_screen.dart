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

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
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
      case 'n-wvd47quy::onTap':
        context.push('/deposit');
        break;
      case 'n-ih8vuxlx::onTap':
        context.push('/withdraw');
        break;
      case 'n-2r1p6w6y::onTap':
        appState.selectedCoin = exprGet(_ctx, <String>['coin']);
        _ctx['state'] = ref.read(appStateProvider);
        context.push('/coin-detail');
        break;
      case 'n-fi4is4lo::onTap':
        context.push('/market');
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
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: StateScope(
                state: ref.watch(appStateProvider),
                child: Builder(
                  builder: (context) => buildNode(
                    context,
                    NodeModel.fromJson(<String, dynamic>{
                      'id': 's-portfolio__root',
                      'type': 'Column',
                      'props': <String, dynamic>{
                        'crossAxisAlignment': 'stretch',
                        'gap': 16,
                        'scrollable': true,
                      },
                      'children': <Map<String, dynamic>>[
                        <String, dynamic>{
                          'id': 'n-z1yebqrh',
                          'type': 'Text',
                          'props': <String, dynamic>{
                            'text': 'Portfolio',
                            'textStyle': 'token:display',
                            'size': 30,
                            'weight': 'w700',
                            'color': 'token:ink',
                          },
                        },
                        <String, dynamic>{
                          'id': 'n-ykftd3nn',
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
                          'layout': {'width': 'fill'},
                          'children': <Map<String, dynamic>>[
                            <String, dynamic>{
                              'id': 'n-sc140njn',
                              'type': 'Column',
                              'props': <String, dynamic>{
                                'gap': 8,
                                'crossAxisAlignment': 'start',
                              },
                              'children': <Map<String, dynamic>>[
                                <String, dynamic>{
                                  'id': 'n-77n73qut',
                                  'type': 'Text',
                                  'props': <String, dynamic>{
                                    'text': 'Holding Value',
                                    'color': '#FFFFFFB3',
                                    'size': 13,
                                  },
                                },
                                <String, dynamic>{
                                  'id': 'n-7hwn5x15',
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
                                    'size': 34,
                                  },
                                },
                                <String, dynamic>{
                                  'id': 'n-6sorxnyf',
                                  'type': 'Row',
                                  'props': <String, dynamic>{'gap': 6},
                                  'layout': {
                                    'width': 'hug',
                                    'margin': {
                                      'top': 2,
                                      'right': 0,
                                      'bottom': 8,
                                      'left': 0,
                                    },
                                  },
                                  'children': <Map<String, dynamic>>[
                                    <String, dynamic>{
                                      'id': 'n-5y4tzt3b',
                                      'type': 'Icon',
                                      'props': <String, dynamic>{
                                        'icon': 'arrow_up_right',
                                        'size': 14,
                                        'color': '#FFFFFF',
                                      },
                                    },
                                    <String, dynamic>{
                                      'id': 'n-j2dscc4p',
                                      'type': 'Text',
                                      'props': <String, dynamic>{
                                        'text':
                                            '+${exprGet(_ctx, <String>['state', 'portfolioChangePct'])}%',
                                        'color': '#FFFFFF',
                                        'size': 13,
                                        'weight': 'w600',
                                      },
                                    },
                                  ],
                                },
                                <String, dynamic>{
                                  'id': 'n-073fvfcy',
                                  'type': 'Row',
                                  'props': <String, dynamic>{
                                    'mainAxisAlignment': 'spaceBetween',
                                  },
                                  'layout': {
                                    'width': 'fill',
                                    'margin': {
                                      'top': 2,
                                      'right': 0,
                                      'bottom': 16,
                                      'left': 0,
                                    },
                                  },
                                  'children': <Map<String, dynamic>>[
                                    <String, dynamic>{
                                      'id': 'n-juvnzbbh',
                                      'type': 'Column',
                                      'props': <String, dynamic>{
                                        'gap': 2,
                                        'crossAxisAlignment': 'start',
                                      },
                                      'children': <Map<String, dynamic>>[
                                        <String, dynamic>{
                                          'id': 'n-ltkpb8hf',
                                          'type': 'Text',
                                          'props': <String, dynamic>{
                                            'text': 'Invested value',
                                            'color': '#FFFFFFB3',
                                            'size': 11,
                                          },
                                        },
                                        <String, dynamic>{
                                          'id': 'n-9syqlfld',
                                          'type': 'AmountDisplay',
                                          'variant': 'Inline',
                                          'props': <String, dynamic>{
                                            'value': exprFormatNumber(
                                              exprGet(_ctx, <String>[
                                                'state',
                                                'portfolioInvested',
                                              ]),
                                              2,
                                            ),
                                            'currency': '\$',
                                            'align': 'left',
                                            'color': '#FFFFFF',
                                            'size': 15,
                                          },
                                        },
                                      ],
                                    },
                                    <String, dynamic>{
                                      'id': 'n-56tyssvd',
                                      'type': 'Column',
                                      'props': <String, dynamic>{
                                        'gap': 2,
                                        'crossAxisAlignment': 'end',
                                      },
                                      'children': <Map<String, dynamic>>[
                                        <String, dynamic>{
                                          'id': 'n-3dhrc1gp',
                                          'type': 'Text',
                                          'props': <String, dynamic>{
                                            'text': 'Available INR',
                                            'color': '#FFFFFFB3',
                                            'size': 11,
                                          },
                                        },
                                        <String, dynamic>{
                                          'id': 'n-ob96mp7o',
                                          'type': 'AmountDisplay',
                                          'variant': 'Inline',
                                          'props': <String, dynamic>{
                                            'value': exprFormatNumber(
                                              exprGet(_ctx, <String>[
                                                'state',
                                                'portfolioAvailable',
                                              ]),
                                              2,
                                            ),
                                            'currency': '\$',
                                            'align': 'right',
                                            'color': '#FFFFFF',
                                            'size': 15,
                                          },
                                        },
                                      ],
                                    },
                                  ],
                                },
                                <String, dynamic>{
                                  'id': 'n-4zkvyes6',
                                  'type': 'Row',
                                  'props': <String, dynamic>{'gap': 12},
                                  'layout': {'width': 'fill'},
                                  'children': <Map<String, dynamic>>[
                                    <String, dynamic>{
                                      'id': 'n-wvd47quy',
                                      'type': 'Button',
                                      'variant': 'Filled',
                                      'props': <String, dynamic>{
                                        'label': 'Deposit',
                                        'primaryColor': '#FFFFFF',
                                        'labelColor': 'token:brandIndigo',
                                        'radius': 999,
                                      },
                                      'events': {
                                        'onTap': [
                                          {
                                            'kind': 'navigate',
                                            'routeId': 'r-deposit',
                                            'mode': 'push',
                                          },
                                        ],
                                      },
                                    },
                                    <String, dynamic>{
                                      'id': 'n-ih8vuxlx',
                                      'type': 'Button',
                                      'variant': 'Outlined',
                                      'props': <String, dynamic>{
                                        'label': 'Withdraw',
                                        'primaryColor': '#FFFFFF',
                                        'radius': 999,
                                      },
                                      'events': {
                                        'onTap': [
                                          {
                                            'kind': 'navigate',
                                            'routeId': 'r-withdraw',
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
                          'id': 'n-kmv8a14c',
                          'type': 'Row',
                          'props': <String, dynamic>{
                            'mainAxisAlignment': 'spaceBetween',
                            'crossAxisAlignment': 'center',
                          },
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
                              'id': 'n-pkl7ihuf',
                              'type': 'Text',
                              'props': <String, dynamic>{
                                'text': 'Your Coins',
                                'textStyle': 'token:heading2',
                                'size': 18,
                                'weight': 'w600',
                                'color': 'token:ink',
                              },
                            },
                            <String, dynamic>{
                              'id': 'n-l05v6yk9',
                              'type': 'Text',
                              'props': <String, dynamic>{
                                'text':
                                    '${exprLen(exprGet(_ctx, <String>['state', 'portfolioHoldings']))} assets',
                                'textStyle': 'token:caption',
                                'size': 12,
                                'weight': 'w500',
                                'color': 'token:inkMuted',
                              },
                            },
                          ],
                        },
                        <String, dynamic>{
                          'id': 'n-px86p7vb',
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
                          '_visible': exprTruthy(
                            (exprLen(
                                  exprGet(_ctx, <String>[
                                    'state',
                                    'portfolioHoldings',
                                  ]),
                                ) >
                                0),
                          ),
                          'separator': <String, dynamic>{
                            'id': 'n-pe3ktvj4',
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
                                  'portfolioHoldings',
                                ]),
                              ),
                              (int _i) => exprWithItem(
                                _ctx,
                                'coin',
                                exprElemAt(
                                  exprGet(_ctx, <String>[
                                    'state',
                                    'portfolioHoldings',
                                  ]),
                                  _i,
                                ),
                                (
                                  Map<String, dynamic> _ctx,
                                ) => <String, dynamic>{
                                  'id': 'n-2r1p6w6y',
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
                                      'id': 'n-barhlmrj',
                                      'type': 'Row',
                                      'props': <String, dynamic>{'gap': 12},
                                      'layout': {'width': 'hug'},
                                      'children': <Map<String, dynamic>>[
                                        <String, dynamic>{
                                          'id': 'n-52o4n01i',
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
                                              'id': 'n-exjs0qwi',
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
                                          'id': 'n-xa622tgm',
                                          'type': 'Column',
                                          'props': <String, dynamic>{
                                            'gap': 2,
                                            'crossAxisAlignment': 'start',
                                          },
                                          'children': <Map<String, dynamic>>[
                                            <String, dynamic>{
                                              'id': 'n-9akmawoy',
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
                                              'id': 'n-rnl3p5z9',
                                              'type': 'Text',
                                              'props': <String, dynamic>{
                                                'text':
                                                    '${exprGet(_ctx, <String>['coin', 'qty'])} ${exprGet(_ctx, <String>['coin', 'symbol'])}',
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
                                      'id': 'n-j2apzedx',
                                      'type': 'Column',
                                      'props': <String, dynamic>{
                                        'gap': 2,
                                        'crossAxisAlignment': 'end',
                                      },
                                      'children': <Map<String, dynamic>>[
                                        <String, dynamic>{
                                          'id': 'n-qlhn75ae',
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
                                          'id': 'n-xxu6l6j9',
                                          'type': 'Row',
                                          'props': <String, dynamic>{
                                            'gap': 2,
                                            'crossAxisAlignment': 'center',
                                          },
                                          'children': <Map<String, dynamic>>[
                                            <String, dynamic>{
                                              'id': 'n-7trfrns6',
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
                                              'id': 'n-axv1ba60',
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
                        <String, dynamic>{
                          'id': 'n-lbdtvj1w',
                          'type': 'Column',
                          'props': <String, dynamic>{
                            'gap': 12,
                            'crossAxisAlignment': 'center',
                            'mainAxisAlignment': 'center',
                          },
                          'layout': {
                            'width': 'fill',
                            'margin': {'top': 32, 'bottom': 8},
                          },
                          '_visible': exprTruthy(
                            (exprLen(
                                  exprGet(_ctx, <String>[
                                    'state',
                                    'portfolioHoldings',
                                  ]),
                                ) ==
                                0),
                          ),
                          'children': <Map<String, dynamic>>[
                            <String, dynamic>{
                              'id': 'n-mqbn7njq',
                              'type': 'Icon',
                              'props': <String, dynamic>{
                                'icon': 'wallet',
                                'size': 40,
                                'color': 'token:inkMuted',
                              },
                            },
                            <String, dynamic>{
                              'id': 'n-2oj9waaz',
                              'type': 'Text',
                              'props': <String, dynamic>{
                                'text': 'Start building your portfolio',
                                'textStyle': 'token:heading2',
                                'align': 'center',
                                'size': 18,
                                'weight': 'w600',
                                'color': 'token:ink',
                              },
                            },
                            <String, dynamic>{
                              'id': 'n-pe8zwe8n',
                              'type': 'Text',
                              'props': <String, dynamic>{
                                'text': 'Buy your first coin to see it here.',
                                'textStyle': 'token:bodyMuted',
                                'align': 'center',
                                'size': 14,
                                'weight': 'w400',
                                'color': 'token:inkMuted',
                              },
                            },
                            <String, dynamic>{
                              'id': 'n-fi4is4lo',
                              'type': 'Button',
                              'variant': 'Filled',
                              'props': <String, dynamic>{
                                'label': 'Browse Market',
                                'primaryColor': 'token:brandIndigo',
                                'radius': 999,
                                'fullWidth': false,
                              },
                              'layout': {
                                'margin': {'top': 8},
                              },
                              'events': {
                                'onTap': [
                                  {
                                    'kind': 'navigate',
                                    'routeId': 'r-market',
                                    'mode': 'push',
                                  },
                                ],
                              },
                            },
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
