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

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> _ctx = <String, dynamic>{
      'state': ref.watch(appStateProvider),
    };
    return AppTheme.scope(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Transactions'),
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
                      'id': 's-history__root',
                      'type': 'Column',
                      'props': <String, dynamic>{
                        'crossAxisAlignment': 'stretch',
                        'gap': 16,
                        'scrollable': true,
                      },
                      'children': <Map<String, dynamic>>[
                        <String, dynamic>{
                          'id': 'n-rjv26b7j',
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
                            'id': 'n-6gklupgt',
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
                                  'transactions',
                                ]),
                              ),
                              (int _i) => exprWithItem(
                                _ctx,
                                'tx',
                                exprElemAt(
                                  exprGet(_ctx, <String>[
                                    'state',
                                    'transactions',
                                  ]),
                                  _i,
                                ),
                                (
                                  Map<String, dynamic> _ctx,
                                ) => <String, dynamic>{
                                  'id': 'n-ha9pdj89',
                                  'type': 'Row',
                                  'props': <String, dynamic>{
                                    'mainAxisAlignment': 'spaceBetween',
                                    'crossAxisAlignment': 'center',
                                  },
                                  'layout': {
                                    'padding': {
                                      'top': 12,
                                      'right': 0,
                                      'bottom': 12,
                                      'left': 0,
                                    },
                                  },
                                  'children': <Map<String, dynamic>>[
                                    <String, dynamic>{
                                      'id': 'n-jpns2w7q',
                                      'type': 'Row',
                                      'props': <String, dynamic>{'gap': 12},
                                      'layout': {'width': 'hug'},
                                      'children': <Map<String, dynamic>>[
                                        <String, dynamic>{
                                          'id': 'n-nsi7pj8c',
                                          'type': 'Container',
                                          'props': <String, dynamic>{
                                            'color': exprGet(_ctx, <String>[
                                              'tx',
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
                                              'id': 'n-exzr5tzd',
                                              'type': 'Image',
                                              'props': <String, dynamic>{
                                                'src': exprGet(_ctx, <String>[
                                                  'tx',
                                                  'icon',
                                                ]),
                                                'fit': 'contain',
                                              },
                                            },
                                          ],
                                        },
                                        <String, dynamic>{
                                          'id': 'n-xvno5q9y',
                                          'type': 'Column',
                                          'props': <String, dynamic>{
                                            'gap': 2,
                                            'crossAxisAlignment': 'start',
                                          },
                                          'children': <Map<String, dynamic>>[
                                            <String, dynamic>{
                                              'id': 'n-silraucj',
                                              'type': 'Text',
                                              'props': <String, dynamic>{
                                                'text':
                                                    '${exprGet(_ctx, <String>['tx', 'type'])} • ${exprGet(_ctx, <String>['tx', 'coin'])}',
                                                'textStyle': 'token:body',
                                                'weight': 'w400',
                                                'size': 15,
                                                'color': 'token:ink',
                                              },
                                            },
                                            <String, dynamic>{
                                              'id': 'n-5fzwk711',
                                              'type': 'Text',
                                              'props': <String, dynamic>{
                                                'text': exprGet(_ctx, <String>[
                                                  'tx',
                                                  'date',
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
                                      'id': 'n-ovbp4ytj',
                                      'type': 'Column',
                                      'props': <String, dynamic>{
                                        'gap': 2,
                                        'crossAxisAlignment': 'end',
                                      },
                                      'children': <Map<String, dynamic>>[
                                        <String, dynamic>{
                                          'id': 'n-zz9rn6qi',
                                          'type': 'AmountDisplay',
                                          'variant': 'Inline',
                                          'props': <String, dynamic>{
                                            'value': exprFormatNumber(
                                              exprGet(_ctx, <String>[
                                                'tx',
                                                'value',
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
                                          'id': 'n-njilkjti',
                                          'type': 'Text',
                                          'props': <String, dynamic>{
                                            'text': exprGet(_ctx, <String>[
                                              'tx',
                                              'status',
                                            ]),
                                            'color': 'token:gainGreen',
                                            'size': 12,
                                            'weight': 'w600',
                                          },
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
