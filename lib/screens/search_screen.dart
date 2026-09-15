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

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
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
      case 'n-97b5v701::onTap':
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
        appBar: AppBar(
          title: Text('Search'),
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
                      'id': 's-search__root',
                      'type': 'Column',
                      'props': <String, dynamic>{
                        'crossAxisAlignment': 'stretch',
                        'gap': 16,
                        'scrollable': true,
                      },
                      'children': <Map<String, dynamic>>[
                        <String, dynamic>{
                          'id': 'n-95mn05lp',
                          'type': 'TextInput',
                          'variant': 'Filled',
                          'props': <String, dynamic>{
                            'placeholder': 'Search Cryptocurrency',
                            'leadingIcon': 'search',
                            'clearButton': true,
                            'radius': 12,
                            'primaryColor': 'token:brandIndigo',
                            'autofocus': true,
                            'value': exprGet(_ctx, <String>[
                              'state',
                              'searchQuery',
                            ]),
                          },
                          'bindValue': 'searchQuery',
                        },
                        <String, dynamic>{
                          'id': 'n-u3rho9f2',
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
                            'id': 'n-03b3732s',
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
                                  'id': 'n-97b5v701',
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
                                    (exprContains(
                                          exprGet(_ctx, <String>[
                                            'coin',
                                            'name',
                                          ]),
                                          exprGet(_ctx, <String>[
                                            'searchQuery',
                                          ]),
                                        ) ||
                                        exprContains(
                                          exprGet(_ctx, <String>[
                                            'coin',
                                            'symbol',
                                          ]),
                                          exprGet(_ctx, <String>[
                                            'searchQuery',
                                          ]),
                                        )),
                                  ),
                                  'children': <Map<String, dynamic>>[
                                    <String, dynamic>{
                                      'id': 'n-vnmuwuh3',
                                      'type': 'Row',
                                      'props': <String, dynamic>{'gap': 12},
                                      'layout': {'width': 'hug'},
                                      'children': <Map<String, dynamic>>[
                                        <String, dynamic>{
                                          'id': 'n-qmwwx8l7',
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
                                              'id': 'n-1vvbf40s',
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
                                          'id': 'n-0exer1y3',
                                          'type': 'Column',
                                          'props': <String, dynamic>{
                                            'gap': 2,
                                            'crossAxisAlignment': 'start',
                                          },
                                          'children': <Map<String, dynamic>>[
                                            <String, dynamic>{
                                              'id': 'n-r0z6xuk8',
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
                                              'id': 'n-jd9vd5zb',
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
                                      'id': 'n-tyygqmsg',
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
