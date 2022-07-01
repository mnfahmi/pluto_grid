import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../helper/column_helper.dart';
import 'visibility_state_test.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<LinkedScrollControllerGroup>(returnNullOnMissingStub: true),
  MockSpec<ScrollController>(returnNullOnMissingStub: true),
  MockSpec<ScrollPosition>(returnNullOnMissingStub: true),
])
void main() {
  PlutoGridStateManager createStateManager({
    required List<PlutoColumn> columns,
    required List<PlutoRow> rows,
    FocusNode? gridFocusNode,
    PlutoGridScrollController? scroll,
    BoxConstraints? layout,
    PlutoGridConfiguration? configuration,
  }) {
    final stateManager = PlutoGridStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: gridFocusNode,
      scroll: scroll,
      configuration: configuration,
    );

    stateManager.setEventManager(
      PlutoGridEventManager(stateManager: stateManager),
    );

    if (layout != null) {
      stateManager.setLayout(layout);
    }

    return stateManager;
  }

  group('updateColumnStartPosition', () {
    testWidgets(
      '비고정 컬럼 5개. 컬럼의 startPosition 이 설정 되어야 한다.',
      (widgetTester) async {
        const defaultWidth = PlutoGridSettings.columnWidth;

        final columns = ColumnHelper.textColumn(
          'column',
          count: 5,
          frozen: PlutoColumnFrozen.none,
        );

        final stateManager = createStateManager(columns: columns, rows: []);

        stateManager.updateVisibility();

        expect(stateManager.columns[0].startPosition, 0);
        expect(stateManager.columns[1].startPosition, defaultWidth * 1);
        expect(stateManager.columns[2].startPosition, defaultWidth * 2);
        expect(stateManager.columns[3].startPosition, defaultWidth * 3);
        expect(stateManager.columns[4].startPosition, defaultWidth * 4);
      },
    );

    testWidgets(
      '비고정 컬럼 5개를 넓이를 변경. 컬럼의 startPosition 이 설정 되어야 한다.',
      (widgetTester) async {
        const defaultWidth = 100.0;

        final columns = ColumnHelper.textColumn(
          'column',
          count: 5,
          width: defaultWidth,
          frozen: PlutoColumnFrozen.none,
        );

        final stateManager = createStateManager(columns: columns, rows: []);

        stateManager.updateVisibility();

        expect(stateManager.columns[0].startPosition, 0);
        expect(stateManager.columns[1].startPosition, defaultWidth * 1);
        expect(stateManager.columns[2].startPosition, defaultWidth * 2);
        expect(stateManager.columns[3].startPosition, defaultWidth * 3);
        expect(stateManager.columns[4].startPosition, defaultWidth * 4);
      },
    );

    testWidgets(
      '비고정 컬럼 5개의 넓이를 각각 변경. 컬럼의 startPosition 이 설정 되어야 한다.',
      (widgetTester) async {
        final widths = <double>[100, 150, 80, 90, 200];

        final columns = ColumnHelper.textColumn(
          'column',
          count: 5,
          frozen: PlutoColumnFrozen.none,
        );

        for (int i = 0; i < columns.length; i += 1) {
          columns[i].width = widths[i];
        }

        final stateManager = createStateManager(columns: columns, rows: []);

        stateManager.updateVisibility();

        double startPosition = 0;

        expect(stateManager.columns[0].startPosition, startPosition);
        startPosition += widths[0];
        expect(stateManager.columns[1].startPosition, startPosition);
        startPosition += widths[1];
        expect(stateManager.columns[2].startPosition, startPosition);
        startPosition += widths[2];
        expect(stateManager.columns[3].startPosition, startPosition);
        startPosition += widths[3];
        expect(stateManager.columns[4].startPosition, startPosition);
      },
    );

    testWidgets(
      '그리드 넓이가 충분한 상태에서.'
      '좌측고정 2개, 비고정 2개, 우측고정 2개. '
      '컬럼의 startPosition 이 설정 되어야 한다.',
      (tester) async {
        const defaultWidth = PlutoGridSettings.columnWidth;

        final columns = [
          ...ColumnHelper.textColumn(
            'left',
            count: 2,
            frozen: PlutoColumnFrozen.left,
          ),
          ...ColumnHelper.textColumn(
            'body',
            count: 2,
            frozen: PlutoColumnFrozen.none,
          ),
          ...ColumnHelper.textColumn(
            'right',
            count: 2,
            frozen: PlutoColumnFrozen.right,
          ),
        ];

        final stateManager = createStateManager(columns: columns, rows: []);
        stateManager.setLayout(const BoxConstraints(maxWidth: 1300));
        expect(stateManager.showFrozenColumn, true);

        stateManager.updateVisibility();

        expect(stateManager.columns[0].startPosition, 0);
        expect(stateManager.columns[1].startPosition, defaultWidth * 1);

        expect(stateManager.columns[2].startPosition, 0);
        expect(stateManager.columns[3].startPosition, defaultWidth * 1);

        expect(stateManager.columns[4].startPosition, 0);
        expect(stateManager.columns[5].startPosition, defaultWidth * 1);
      },
    );

    testWidgets(
      '그리드 넓이가 부족한 상태에서.'
      '좌측고정 2개, 비고정 2개, 우측고정 2개. '
      '컬럼의 startPosition 이 설정 되어야 한다.',
      (tester) async {
        const defaultWidth = PlutoGridSettings.columnWidth;

        final columns = [
          ...ColumnHelper.textColumn(
            'left',
            count: 2,
            frozen: PlutoColumnFrozen.left,
          ),
          ...ColumnHelper.textColumn(
            'body',
            count: 2,
            frozen: PlutoColumnFrozen.none,
          ),
          ...ColumnHelper.textColumn(
            'right',
            count: 2,
            frozen: PlutoColumnFrozen.right,
          ),
        ];

        final stateManager = createStateManager(columns: columns, rows: []);
        stateManager.setLayout(const BoxConstraints(maxWidth: 600));
        expect(stateManager.showFrozenColumn, false);

        stateManager.updateVisibility();

        expect(stateManager.columns[0].startPosition, 0);
        expect(stateManager.columns[1].startPosition, defaultWidth * 1);

        expect(stateManager.columns[2].startPosition, defaultWidth * 2);
        expect(stateManager.columns[3].startPosition, defaultWidth * 3);

        expect(stateManager.columns[4].startPosition, defaultWidth * 4);
        expect(stateManager.columns[5].startPosition, defaultWidth * 5);
      },
    );

    testWidgets(
      '숨김컬럼 1개, 비고정 컬럼 4개. 컬럼의 startPosition 이 설정 되어야 한다.',
      (widgetTester) async {
        const defaultWidth = PlutoGridSettings.columnWidth;

        final columns = ColumnHelper.textColumn(
          'column',
          count: 5,
          frozen: PlutoColumnFrozen.none,
        );

        columns[2].hide = true;

        final stateManager = createStateManager(columns: columns, rows: []);

        stateManager.updateVisibility();

        expect(stateManager.refColumns.originalList[0].startPosition, 0);
        expect(
          stateManager.refColumns.originalList[1].startPosition,
          defaultWidth * 1,
        );

        // 숨김컬럼은 기본값 0
        expect(
          stateManager.refColumns.originalList[2].startPosition,
          0,
        );

        expect(
          stateManager.refColumns.originalList[3].startPosition,
          defaultWidth * 2,
        );
        expect(
          stateManager.refColumns.originalList[4].startPosition,
          defaultWidth * 3,
        );
      },
    );

    testWidgets(
      'applyViewportDimension 이 호출 되어야 한다.',
      (widgetTester) async {
        final LinkedScrollControllerGroup horizontalScroll =
            MockLinkedScrollControllerGroup();

        final ScrollController rowsScroll = MockScrollController();

        final ScrollPosition scrollPosition = MockScrollPosition();

        when(rowsScroll.position).thenReturn(scrollPosition);

        when(scrollPosition.hasViewportDimension).thenReturn(true);

        final columns = ColumnHelper.textColumn(
          'column',
          count: 5,
          frozen: PlutoColumnFrozen.none,
        );

        final stateManager = createStateManager(
          columns: columns,
          rows: [],
          scroll: PlutoGridScrollController(
            horizontal: horizontalScroll,
          ),
          layout: const BoxConstraints(maxWidth: 800),
        );

        stateManager.scroll!.setBodyRowsHorizontal(rowsScroll);

        // setLayout 메서드에서 applyViewportDimension 한번 호출 되어 리셋.
        reset(horizontalScroll);

        stateManager.updateVisibility();

        final bodyWidth = stateManager.maxWidth! -
            stateManager.bodyLeftOffset -
            stateManager.bodyRightOffset;

        verify(horizontalScroll.applyViewportDimension(bodyWidth)).called(1);
      },
    );

    testWidgets(
      'notify = true 인 경우, notifyListeners 이 호출 되어야 한다.',
      (widgetTester) async {
        final LinkedScrollControllerGroup horizontalScroll =
            MockLinkedScrollControllerGroup();

        final columns = ColumnHelper.textColumn(
          'column',
          count: 5,
          frozen: PlutoColumnFrozen.none,
        );

        final stateManager = createStateManager(
          columns: columns,
          rows: [],
          scroll: PlutoGridScrollController(
            horizontal: horizontalScroll,
          ),
          layout: const BoxConstraints(maxWidth: 800),
        );

        stateManager.updateVisibility(notify: true);

        verify(horizontalScroll.notifyListeners()).called(1);
      },
    );

    testWidgets(
      'notify = false 인 경우, notifyListeners 이 호출 되지 않아야 한다.',
      (widgetTester) async {
        final LinkedScrollControllerGroup horizontalScroll =
            MockLinkedScrollControllerGroup();

        final columns = ColumnHelper.textColumn(
          'column',
          count: 5,
          frozen: PlutoColumnFrozen.none,
        );

        final stateManager = createStateManager(
          columns: columns,
          rows: [],
          scroll: PlutoGridScrollController(
            horizontal: horizontalScroll,
          ),
          layout: const BoxConstraints(maxWidth: 800),
        );

        stateManager.updateVisibility(notify: false);

        verifyNever(horizontalScroll.notifyListeners());
      },
    );
  });
}
