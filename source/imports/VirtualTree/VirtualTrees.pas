unit VirtualTrees;

// Version 3.0.4
//
// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
// specific language governing rights and limitations under the License.
//
// The original code is VirtualTrees.pas, released September 30, 2000.
//
// The initial developer of the original code is digital publishing AG (Munich, Germany, www.digitalpublishing.de),
// written by Dipl. Ing. Mike Lischke (public@lischke-online.de, www.lischke-online.de).
//
// Portions created by digital publishing AG are Copyright
// (C) 1999-2001 digital publishing AG. All Rights Reserved.
//----------------------------------------------------------------------------------------------------------------------
//
// JAN-2002
//   - Switch to major version 3.
//   - Wheel panning and auto scrolling, option toWheelPanning
//   - vsClearing node state for optimizations
//   - Update*Scrollbar methods are now public
//   - toAutoAcceptEditChange
//   - MoveTo within a tree now keeps focused node instead resetting it
//
// For full document history see help file.
//
// Credits for their valuable assistance and code donations go to:
//   Freddy Ertl, Marian Aldenh�vel, Thomas Bogenrieder, Jim Kuenemann, Werner Lehmann, Jens Treichler,
//   Paul Gallagher (IBO tree), Ondrej Kelle, Ronaldo Melo Ferraz, Heri Bender, Roland Bed�rftig (BCB)
//   Anthony Mills, Alexander Egorushkin (BCB), Mathias Torell (BCB), Frank van den Bergh, Vadim Sedulin, Peter Evans,
//   Milan Vandrovec
// Beta testers:
//   Freddy Ertl, Hans-J�rgen Schnorrenberg, Werner Lehmann, Jim Kueneman, Vadim Sedulin, Moritz Franckenstein,
//   Wim van der Vegt, Franc v/d Westelaken
// Indirect contribution (via publicly accessible work of those persons):
//   Alex Denissov, Hiroyuki Hori (MMXAsm expert)
// Documentation:
//   John Knipper (FAQ), Sven H. (Step by step tutorial)
//----------------------------------------------------------------------------------------------------------------------

interface

{$I Compilers.inc}
{.$define UseFlatScrollbars}
{.$define ReverseFullExpandHotKey} // Used to define Ctrl+'+' instead of Ctrl+Shift+'+' for full expand (and similar for collapsing).

{$HPPEMIT '#include <objidl.h>'}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, ImgList, ActiveX, StdCtrls, Menus,
  JwaUxTheme, JwaTmSchema;  // Windows XP themes support

const
  VTVersion = '3.0.4';
  VTTreeStreamVersion = 2;
  VTHeaderStreamVersion = 2;    // The header needs an own stream version to indicate changes only relevant to the header.

  CacheThreshold = 2000;        // Number of nodes a tree must at least have to start caching and at the same
                                // time the maximum number of nodes between two cache entries.
  FadeAnimationStepCount = 255; // Number of animation steps for hint fading (0..255).
  ShadowSize = 5;               // Size in pixels of the hint shadow. Set to 0 if you don't want shadows.

  // Special identifiers for columns.
  NoColumn = -1;
  InvalidColumn = -2;

  // Indices for check state images used for checking.
  ckEmpty                  =  0;  // an empty image used as place holder
  // radio buttons
  ckRadioUncheckedNormal   =  1;
  ckRadioUncheckedHot      =  2;
  ckRadioUncheckedPressed  =  3;
  ckRadioUncheckedDisabled =  4;
  ckRadioCheckedNormal     =  5;
  ckRadioCheckedHot        =  6;
  ckRadioCheckedPressed    =  7;
  ckRadioCheckedDisabled   =  8;
  // check boxes
  ckCheckUncheckedNormal   =  9;
  ckCheckUncheckedHot      = 10;
  ckCheckUncheckedPressed  = 11;
  ckCheckUncheckedDisabled = 12;
  ckCheckCheckedNormal     = 13;
  ckCheckCheckedHot        = 14;
  ckCheckCheckedPressed    = 15;
  ckCheckCheckedDisabled   = 16;
  ckCheckMixedNormal       = 17;
  ckCheckMixedHot          = 18;
  ckCheckMixedPressed      = 19;
  ckCheckMixedDisabled     = 20;
  // simple button
  ckButtonNormal           = 21;
  ckButtonHot              = 22;
  ckButtonPressed          = 23;
  ckButtonDisabled         = 24;

  // Instead using a TTimer class for each of the various events I use Windows timers with messages
  // as this is more economical.
  ExpandTimer = 1;
  EditTimer = 2;
  HeaderTimer = 3;
  ScrollTimer = 4;
  ChangeTimer = 5;
  StructureChangeTimer = 6;
  SearchTimer = 7;

  // Need to use this message to release the edit link interface asynchronly.
  WM_RELEASEEDITLINK = WM_APP + 31;

  // VT's own clipboard formats,
  // Note: The reference format is used internally to allow to link to a tree reference
  //       to implement optimized moves and other back references.
  CFSTR_VIRTUALTREE = 'Virtual Tree Data';
  CFSTR_VTREFERENCE = 'Virtual Tree Reference';
  CFSTR_HTML = 'HTML Format';
  CFSTR_RTF = 'Rich Text Format';
  CFSTR_RTFNOOBJS = 'Rich Text Format Without Objects';
  CFSTR_CSV = 'CSV';

  // Drag image helpers for Windows 2000 and up.
  IID_IDropTargetHelper: TGUID = (D1: $4657278B; D2: $411B; D3: $11D2; D4: ($83, $9A, $00, $C0, $4F, $D9, $18, $D0));
  IID_IDragSourceHelper: TGUID = (D1: $DE5BF786; D2: $477A; D3: $11D2; D4: ($83, $9D, $00, $C0, $4F, $D9, $18, $D0));
  IID_IDropTarget: TGUID = (D1: $00000122; D2: $0000; D3: $0000; D4: ($C0, $00, $00, $00, $00, $00, $00, $46));
  CLSID_DragDropHelper: TGUID = (D1: $4657278A; D2: $411B; D3: $11D2; D4: ($83, $9A, $00, $C0, $4F, $D9, $18, $D0));

  SID_IDropTargetHelper = '{4657278B-411B-11D2-839A-00C04FD918D0}';
  SID_IDragSourceHelper = '{DE5BF786-477A-11D2-839D-00C04FD918D0}';
  SID_IDropTarget = '{00000122-0000-0000-C000-000000000046}';

  // Help identifiers for exceptions. Application developers are responsible to link them with actual help topics.
  hcTFEditLinkIsNil      = 2000;
  hcTFWrongMoveError     = 2001;
  hcTFWrongStreamFormat  = 2002;
  hcTFWrongStreamVersion = 2003;
  hcTFStreamTooSmall     = 2004;
  hcTFCorruptStream1     = 2005;
  hcTFCorruptStream2     = 2006;
  hcTFClipboardFailed    = 2007;
  hcTFCannotSetUserData  = 2008;
  
var // Clipboard format IDs used in OLE drag'n drop and clipboard transfers.
  CF_VIRTUALTREE,
  CF_VTREFERENCE,
  CF_VRTF,
  CF_VRTFNOOBJS,   // Unfortunately CF_RTF* is already defined as being
                   // registration strings so I have to use different identifiers.
  CF_HTML,
  CF_CSV: Word;

  MMXAvailable: Boolean; // necessary to know because the blend code uses MMX instructions

{$MinEnumSize 1, make enumerations as small as possible}

type
  // The exception used by the trees.
  EVirtualTreeError = class(Exception);

  PCardinal = ^Cardinal;

  // Limits the speed interval which can be used for auto scrolling (milliseconds).
  TAutoScrollInterval = 1..1000;

  // Need to declare the correct WMNCPaint record as the VCL (D5-) doesn't.
  TRealWMNCPaint = packed record
    Msg: Cardinal;
    Rgn: HRGN;
    lParam: Integer;
    Result: Integer;
  end;

  // The next both message records are not declared in Delphi 5 and lower.
  TWMPrint = packed record
    Msg: Cardinal;
    DC: HDC;
    Flags: Cardinal;
    Result: Integer;
  end;

  TWMPrintClient = TWMPrint;

  {$ifndef COMPILER_5_UP}
    TWMContextMenu = TWMMouse;
  {$endif COMPILER_5_UP}

  // Be careful when adding new states as this might change the size of the type which in turn
  // changes the alignment in the node record as well as the stream chunks.
  // Do not reorder the states and always add new states at the end of this enumeration in order to avoid
  // breaking existing code. 
  TVirtualNodeState = (
    vsInitialized,       // Set after the node has been initialized.
    vsChecking,          // Node's check state is changing, avoid propagation.
    vsCutOrCopy,         // Node is selected as cut or copy and paste source.
    vsDisabled,          // Set if node is disabled.
    vsDeleting,          // Set when the node is about to be freed.
    vsExpanded,          // Set if the node is expanded.
    vsHasChildren,       // Indicates the presence of child nodes without actually setting them.
    vsVisible,           // Indicate whether the node is visible or not (independant of the expand states of its parents).
    vsSelected,          // Set if the node in the current selection.
    vsInitialUserData,   // Set if (via AddChild or InsertNode) initial user data has been set which requires OnFreeNode.
    vsAllChildrenHidden, // Set if vsHasChildren is set and no child node has the vsVisible flag set.
    vsClearing           // Nodes children are being deleted. Don't register structure change event.
  );
  TVirtualNodeStates = set of TVirtualNodeState;

  // States used in InitNode to indicate states a node shall initially have.
  TVirtualNodeInitState = ( 
    ivsDisabled,
    ivsExpanded,
    ivsHasChildren,
    ivsSelected
  );
  TVirtualNodeInitStates = set of TVirtualNodeInitState;

  TScrollBarStyle = (
    sbmRegular,
    sbmFlat,
    sbm3D
  );
          
  // options per column
  TVTColumnOption = (
    coAllowClick,
    coDraggable,
    coEnabled,
    coParentBidiMode,
    coParentColor,
    coResizable,
    coShowDropMark,
    coVisible
  );
  TVTColumnOptions = set of TVTColumnOption;

  // These flags are returned by the hit test method.
  THitPosition = (
    hiAbove,          // above the client area (if relative) or the absolute tree area
    hiBelow,          // below the client area (if relative) or the absolute tree area
    hiNowhere,        // no node is involved (possible only if the tree is not as tall as the client area)
    hiOnItem,         // on the bitmaps/buttons or label associated with an item
    hiOnItemButton,   // on the button associated with an item
    hiOnItemCheckbox, // on the checkbox if enabled
    hiOnItemIndent,   // in the indentation area in front of a node
    hiOnItemLabel,    // on the normal text area associated with an item
    hiOnItemLeft,     // in the area to the left of a node's text area (e.g. when right aligned or centered)
    hiOnItemRight,    // in the area to the right of a node's text area (e.g. if left aligned or centered)
    hiOnNormalIcon,   // on the "normal" image
    hiOnStateIcon,    // on the state image
    hiToLeft,         // to the left of the client area (if relative) or the absolute tree area
    hiToRight         // to the right of the client area (if relative) or the absolute tree area
  );
  THitPositions = set of THitPosition;

  TCheckType = (
    ctNone,
    ctTriStateCheckBox,
    ctCheckBox,
    ctRadioButton,
    ctButton
  );

  // The check states include both, transient and fluent (temporary) states. The only temporary state defined so
  // far is the pressed state.
  TCheckState = (
    csUncheckedNormal,  // unchecked and not pressed
    csUncheckedPressed, // unchecked and pressed
    csCheckedNormal,    // checked and not pressed
    csCheckedPressed,   // checked and pressed
    csMixedNormal,      // 3-state check box and not pressed
    csMixedPressed      // 3-state check box and pressed
  );

  TCheckImageKind = (
    ckLightCheck,     // gray cross
    ckDarkCheck,      // black cross
    ckLightTick,      // gray tick mark
    ckDarkTick,       // black tick mark
    ckFlat,           // flat images (no 3D border)
    ckXP,             // Windows XP style
    ckCustom          // application defined check images
  );

  // mode to describe a move action
  TVTNodeAttachMode = (
    amNoWhere,        // just for simplified tests, means to ignore the Add/Insert command
    amInsertBefore,   // insert node just before destination (as sibling of destination)
    amInsertAfter,    // insert node just after destionation (as sibling of destination)
    amAddChildFirst,  // add node as first child of destination
    amAddChildLast    // add node as last child of destination
  );

  // modes to determine drop position further
  TDropMode = (
    dmNowhere,
    dmAbove,
    dmOnNode,
    dmBelow
  );

  // operations basically allowed during drag'n drop
  TDragOperation = (
    doCopy,
    doMove,
    doLink
  );
  TDragOperations = set of TDragOperation;

  TVTImageKind = (
    ikNormal,
    ikSelected,
    ikState,
    ikOverlay
  );

  TVTHintMode = (
    hmDefault,            // show the hint of the control
    hmHint,               // show node specific hint string returned by the application
    hmHintAndDefault,     // same as hmHint but show the control's hint if no node is concerned
    hmTooltip             // show the text of the node if it isn't already fully shown
  );

  TMouseButtons = set of TMouseButton;

  // Used to describe the action to do when using the OnBeforeItemErase event.
  TItemEraseAction = (
    eaColor,   // use the provided color to erase the background instead the one of the tree
    eaDefault  // the tree should erase the item's background (bitmap or solid)
  );

  
  // There is a heap of switchable behavior in the tree. Since published properties may never exceed 4 bytes,
  // which limits sets to at most 32 members, and because for better overview tree options are splitted
  // in various sub-options and are held in a commom options class.
  //
  // Options to cusomize tree appearance:
  TVTPaintOption = (
    toHideFocusRect,           // Avoid drawing the dotted rectangle around the currently focused node.
    toHideSelection,           // Selected nodes are drawn as unselected nodes if the tree is unfocused.
    toHotTrack,                // Track which node is under the mouse cursor (needed also for "hot" check images).
    toPopupMode,               // Paint tree as would it always have the focus (useful for tree combo boxes etc.)
    toShowBackground,          // Use the background image if there's one.
    toShowButtons,             // Display collapse/expand buttons left to a node.
    toShowDropmark,            // Show the dropmark during drag'n drop operations.
    toShowHorzGridLines,       // Display horizontal lines to simulate a grid.
    toShowRoot,                // Show lines also at top level (does not show the hidden/internal root node).
    toShowTreeLines,           // Display tree lines to show hierarchy of nodes.
    toShowVertGridLines,       // Display vertical lines (depending on columns) to simulate a grid.
    toThemeAware,              // Draw UI elements (header, tree buttons etc.) according to the current theme if
                               // enabled (Windows XP+ only, application must be themed).
    toUseBlendedImages         // Enable alpha blending for ghosted nodes or those which are being cut/copied.
  );
  TVTPaintOptions = set of TVTPaintOption;

  // Options to toggle animation support:
  TVTAnimationOption = (
    toAnimatedToggle           // Expanding and collapsing a node is animated (quick window scroll).
  );
  TVTAnimationOptions = set of TVTAnimationOption;

  // Options which toggle automatic handling of certain situations:
  TVTAutoOption = (
    toAutoDropExpand,          // Expand node if it is the drop target for more than certain time.
    toAutoExpand,              // Nodes are expanded (collapsed) when getting (losing) the focus.
    toAutoScroll,              // Scroll if mouse is near the border while dragging or selecting.
    toAutoScrollOnExpand,      // Scroll as many child nodes in view as possible after expanding a node.
    toAutoSort,                // Sort tree when Header.SortColumn or Header.SortDirection change or sort node if
                               // child nodes are added.
    toAutoSpanColumns,         // Large entries continue into next column(s) if there's no text in them (no clipping).
    toAutoTristateTracking,    // Checkstates are automatically propagated for tri state check boxes.
    toAutoHideButtons,         // Node buttons are hidden when there are child nodes, but all are invisible.
    toAutoDeleteMovedNodes     // Delete nodes which where moved in a drag operation (if not directed otherwise).
  );
  TVTAutoOptions = set of TVTAutoOption;

  // Options which determine the tree's behavior when selecting nodes:
  TVTSelectionOption = (
    toDisableDrawSelection,    // Prevent user from selecting with the selection rectangle in multiselect mode.
    toExtendedFocus,           // Entries other than in the main column can be selected, edited etc.
    toFullRowSelect,           // Hit test as well as selection highlight are not constrained to the text of a node.
    toLevelSelectConstraint,   // Constrain selection to the same level as the selection anchor.
    toMiddleClickSelect,       // Allow selection, dragging etc. with the middle mouse button. This and toWheelPanning
                               // are mutual exclusive.
    toMultiSelect,             // Allow more than one node to be selected.
    toRightClickSelect,        // Allow selection, dragging etc. with the right mouse button.
    toSiblingSelectConstraint, // constrain selection to nodes with same parent
    toCenterScrollIntoView     // Center nodes vertically in the client area when scrolling into view.
  );
  TVTSelectionOptions = set of TVTSelectionOption;

  // Options which do not fit into any of the other groups:
  TVTMiscOption = (
    toAcceptOLEDrop,           // Register tree as OLE accepting drop target
    toCheckSupport,            // Show checkboxes/radio buttons.
    toEditable,                // Node captions can be edited.
    toFullRepaintOnResize,     // Fully invalidate the tree when its window is resized (CS_HREDRAW/CS_VREDRAW).
    toGridExtensions,          // Use some special enhancements to simulate and support grid behavior.
    toInitOnSave,              // Initialize nodes when saving a tree to a stream.
    toReportMode,              // Tree behaves like TListView in report mode.
    toToggleOnDblClick,        // Toggle node expansion state when it is double clicked.
    toWheelPanning             // Support for mouse panning (wheel mice only). This option and toMiddleClickSelect are
                               // mutal exclusive, where panning has precedence.
  );
  TVTMiscOptions = set of TVTMiscOption;

const
  DefaultPaintOptions = [toShowButtons, toShowButtons, toShowDropmark, toShowTreeLines, toShowRoot, toThemeAware,
    toUseBlendedImages];
  DefaultAnimationOptions = [];
  DefaultAutoOptions = [toAutoDropExpand, toAutoTristateTracking, toAutoScrollOnExpand, toAutoDeleteMovedNodes];
  DefaultSelectionOptions = [];
  DefaultMiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning];
  DefaultColumnOptions = [coAllowClick, coDraggable, coEnabled, coParentColor, coParentBidiMode, coResizable,
    coShowDropmark, coVisible];

type
  TBaseVirtualTree = class;
  TVirtualTreeClass = class of TBaseVirtualTree;

  PVirtualNode = ^TVirtualNode;

  // This record must already be defined here and not later because otherwise BCB users will not be able
  // to compile (conversion done by BCB is wrong).
  TCacheEntry = record
    Node: PVirtualNode;
    AbsoluteTop: Cardinal;
  end;

  TCache = array of TCacheEntry;
  TNodeArray = array of PVirtualNode;

  TCustomVirtualTreeOptions = class(TPersistent)
  private
    FOwner: TBaseVirtualTree;
    FPaintOptions: TVTPaintOptions;                           
    FAnimationOptions: TVTAnimationOptions;
    FAutoOptions: TVTAutoOptions;
    FSelectionOptions: TVTSelectionOptions;
    FMiscOptions: TVTMiscOptions;
    procedure SetAnimationOptions(const Value: TVTAnimationOptions);
    procedure SetAutoOptions(const Value: TVTAutoOptions);
    procedure SetMiscOptions(const Value: TVTMiscOptions);
    procedure SetPaintOptions(const Value: TVTPaintOptions);
    procedure SetSelectionOptions(const Value: TVTSelectionOptions);
  protected
    property AnimationOptions: TVTAnimationOptions read FAnimationOptions write SetAnimationOptions
      default DefaultAnimationOptions;
    property AutoOptions: TVTAutoOptions read FAutoOptions write SetAutoOptions default DefaultAutoOptions;
    property MiscOptions: TVTMiscOptions read FMiscOptions write SetMiscOptions default DefaultMiscOptions;
    property PaintOptions: TVTPaintOptions read FPaintOptions write SetPaintOptions default DefaultPaintOptions;
    property SelectionOptions: TVTSelectionOptions read FSelectionOptions write SetSelectionOptions
      default DefaultSelectionOptions;
  public
    constructor Create(AOwner: TBaseVirtualTree); virtual;

    procedure AssignTo(Dest: TPersistent); override;

    property Owner: TBaseVirtualTree read FOwner;
  end;

  TTreeOptionsClass = class of TCustomVirtualTreeOptions;
  
  TVirtualTreeOptions = class(TCustomVirtualTreeOptions)
  published
    property AnimationOptions;
    property AutoOptions;
    property MiscOptions;
    property PaintOptions;
    property SelectionOptions;
  end;

  // Used to cache the column strings and widths of one node during a paint cycle to optimize access.
  TColumnData = record
    Visible: Boolean;
    Text: WideString;
    Width: Cardinal;
    Bidi: TBidiMode;
  end;

  // Used in the CF_VTREFERENCE clipboard format.
  PVTReference = ^TVTReference;
  TVTReference = record
    Process: Cardinal;
    Tree: TBaseVirtualTree;
  end;

  TVirtualNode = packed record
    Index,                   // index of node with regard to its parent
    ChildCount: Cardinal;    // number of child nodes
    NodeHeight: Word;        // height in pixels
    States: TVirtualNodeStates; // states describing various properties of the node (expanded, initialized etc.)
    Align: Byte;             // line/button alignment
    CheckState: TCheckState; // indicates the current check state (e.g. checked, pressed etc.)
    CheckType: TCheckType;   // indicates which check type shall be used for this node
    Dummy: Byte;             // dummy value to fill DWORD boundary 
    TotalCount,              // sum of this node, all of its child nodes and their child nodes etc.
    TotalHeight: Cardinal;   // height in pixels this node covers on screen including the height of all of its
                             // children
    // Note: Some copy routines require that all pointers (as well as the data area) in a node are
    //       located at the end of the node! Hence if you want to add new member fields (except pointers to internal
    //       data) then put them before field Parent.
    Parent,                  // reference to the node's parent (for the root this contains the treeview)
    PrevSibling,             // link to the node's previous sibling or nil if it is the first node
    NextSibling,             // link to the node's next sibling or nil if it is the last node
    FirstChild,              // link to the node's first child...
    LastChild: PVirtualNode; // link to the node's last child...
    Data: record end;        // this is a placeholder, each node gets extra data determined by NodeDataSize
  end;

  // structure used when info about a certain position in the tree is needed
  THitInfo = record
    HitNode: PVirtualNode;
    HitPositions: THitPositions;
    HitColumn: Integer;
  end;

  // auto scroll directions
  TScrollDirections = set of (
    sdLeft,
    sdUp,
    sdRight,
    sdDown
  );

  // OLE drag'n drop support
  TFormatEtcArray = array of TFormatEtc;
  TFormatArray = array of Word;

  // IDataObject.SetData support
  TInternalStgMedium = packed record
    Format: TClipFormat;
    Medium: TStgMedium;
  end;
  TInternalStgMediumArray = array of TInternalStgMedium;

  TEnumFormatEtc = class(TInterfacedObject, IEnumFormatEtc)
  private
    FTree: TBaseVirtualTree;
    FFormatEtcArray: TFormatEtcArray;
    FCurrentIndex: Integer;
  public
    constructor Create(Tree: TBaseVirtualTree; AFormatEtcArray: TFormatEtcArray);

    function Clone(out Enum: IEnumFormatEtc): HResult; stdcall;
    function Next(celt: Integer; out elt; pceltFetched: PLongint): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Skip(celt: Integer): HResult; stdcall;
  end;

  // ----- OLE drag'n drop handling
  IDropTargetHelper = interface(IUnknown)
    [SID_IDropTargetHelper]
    function DragEnter(hwndTarget: HWND; pDataObject: IDataObject; var ppt: TPoint; dwEffect: Integer): HRESULT; stdcall;
    function DragLeave: HRESULT; stdcall;
    function DragOver(var ppt: TPoint; dwEffect: Integer): HRESULT; stdcall;
    function Drop(pDataObject: IDataObject; var ppt: TPoint; dwEffect: Integer): HRESULT; stdcall;
    function Show(fShow: Boolean): HRESULT; stdcall;
  end;

  PSHDragImage = ^TSHDragImage;
  TSHDragImage = packed record
    sizeDragImage: TSize;
    ptOffset: TPoint;
    hbmpDragImage: HBITMAP;
    ColorRef: TColorRef;
  end;

  IDragSourceHelper = interface(IUnknown)
    [SID_IDragSourceHelper]
    function InitializeFromBitmap(var SHDragImage: TSHDragImage; pDataObject: IDataObject): HRESULT; stdcall;
    function InitializeFromWindow(Window: HWND; var ppt: TPoint; pDataObject: IDataObject): HRESULT; stdcall;
  end;

  IVTDragManager = interface(IUnknown)
    ['{C4B25559-14DA-446B-8901-0C879000EB16}']
    function GetDataObject: IDataObject; stdcall;
    function GetDragSource: TBaseVirtualTree; stdcall;
    function GetDropTargetHelperSupported: Boolean; stdcall;
    function GetIsDropTarget: Boolean; stdcall;

    property DataObject: IDataObject read GetDataObject;
    property DragSource: TBaseVirtualTree read GetDragSource;
    property DropTargetHelperSupported: Boolean read GetDropTargetHelperSupported;
    property IsDropTarget: Boolean read GetIsDropTarget;
  end;

  // This data object is used in two different places. One is for clipboard operations and the other while dragging.
  TVTDataObject = class(TInterfacedObject, IDataObject)
  private
    FOwner: TBaseVirtualTree;          // The tree which provides clipboard or drag data.
    FForClipboard: Boolean;            // Determines which data to render with GetData.
    FFormatEtcArray: TFormatEtcArray;
    FInternalStgMediumArray: TInternalStgMediumArray;  // The available formats in the DataObject
    FAdviseHolder: IDataAdviseHolder;  // Reference to an OLE supplied implementation for advising.
  protected
    function CanonicalIUnknown(TestUnknown: IUnknown): IUnknown;
    function EqualFormatEtc(FormatEtc1, FormatEtc2: TFormatEtc): Boolean;
    function FindFormatEtc(TestFormatEtc: TFormatEtc; const FormatEtcArray: TFormatEtcArray): integer;
    function FindInternalStgMedium(Format: TClipFormat): PStgMedium;
    function HGlobalClone(HGlobal: THandle): THandle;
    function RenderInternalOLEData(const FormatEtcIn: TFormatEtc; var Medium: TStgMedium; var OLEResult: HResult): Boolean;
    function StgMediumIncRef(const InStgMedium: TStgMedium; var OutStgMedium: TStgMedium;
      CopyInMedium: Boolean; DataObject: IDataObject): HRESULT;

    property ForClipboard: Boolean read FForClipboard;
    property FormatEtcArray: TFormatEtcArray read FFormatEtcArray write FFormatEtcArray;
    property InternalStgMediumArray: TInternalStgMediumArray read FInternalStgMediumArray write FInternalStgMediumArray;
    property Owner: TBaseVirtualTree read FOwner;
  public
    constructor Create(AOwner: TBaseVirtualTree; ForClipboard: Boolean); virtual;
    destructor Destroy; override;

    function DAdvise(const FormatEtc: TFormatEtc; advf: Integer; const advSink: IAdviseSink; out dwConnection: Integer):
      HResult; virtual; stdcall;
    function DUnadvise(dwConnection: Integer): HResult; virtual; stdcall;
    function EnumDAdvise(out enumAdvise: IEnumStatData): HResult; virtual; stdcall;
    function EnumFormatEtc(Direction: Integer; out EnumFormatEtc: IEnumFormatEtc): HResult; virtual; stdcall;
    function GetCanonicalFormatEtc(const FormatEtc: TFormatEtc; out FormatEtcOut: TFormatEtc): HResult; virtual; stdcall;
    function GetData(const FormatEtcIn: TFormatEtc; out Medium: TStgMedium): HResult; virtual; stdcall;
    function GetDataHere(const FormatEtc: TFormatEtc; out Medium: TStgMedium): HResult; virtual; stdcall;
    function QueryGetData(const FormatEtc: TFormatEtc): HResult; virtual; stdcall;
    function SetData(const FormatEtc: TFormatEtc; var Medium: TStgMedium; DoRelease: BOOL): HResult; virtual; stdcall;
  end;

  // TVTDragManager is a class to manage drag and drop in a Virtual Treeview.
  TVTDragManager = class(TInterfacedObject, IVTDragManager, IDropSource, IDropTarget)
  private
    FOwner,                            // The tree which is responsible for drag management.
    FDragSource: TBaseVirtualTree;     // Reference to the source tree if the source was a VT, might be different than
                                       // the owner tree.
    FIsDropTarget: Boolean;            // True if the owner is currently the drop target.
    FDataObject: IDataObject;          // A reference to the data object passed in by DragEnter (only used when the owner
                                       // tree is the current drop target).
    FDropTargetHelper: IDropTargetHelper; // Win2k > Drag image support

    function GetDataObject: IDataObject; stdcall;
    function GetDragSource: TBaseVirtualTree; stdcall;
    function GetDropTargetHelperSupported: Boolean; stdcall;
    function GetIsDropTarget: Boolean; stdcall;
  public
    constructor Create(AOwner: TBaseVirtualTree); virtual;
    destructor Destroy; override;

    function DragEnter(const DataObject: IDataObject; KeyState: Integer; Pt: TPoint;
      var Effect: Integer): HResult; stdcall;
    function DragLeave: HResult; stdcall;
    function DragOver(KeyState: Integer; Pt: TPoint; var Effect: Integer): HResult; stdcall;
    function Drop(const DataObject: IDataObject; KeyState: Integer; Pt: TPoint; var Effect: Integer): HResult; stdcall;
    function GiveFeedback(Effect: Integer): HResult; stdcall;
    function QueryContinueDrag(EscapePressed: BOOL; KeyState: Integer): HResult; stdcall;
  end;

  PHintData = ^TVTHintData;
  TVTHintData = record
    Tree: TBaseVirtualTree;
    Node: PVirtualNode;
    Column: Integer;
    HintRect: TRect;         // used for draw trees only, string trees get the size from the hint string
    DefaultHint: WideString; // used only if there is no node specific hint string available
                             // or a header hint is about to appear
    HintText: WideString;    // set when size of the hint window is calculated
    BidiMode: TBidiMode;
    Alignment: TAlignment;
  end;

  // Determines the kind of animation when a hint is activated.
  THintAnimationType = (
    hatNone,                 // no animation at all, just display hint/tooltip
    hatFade,                 // fade in the hint/tooltip, like in Windows 2000
    hatSlide,                // slide in the hint/tooltip, like in Windows 98
    hatSystemDefault         // use what the system is using (slide for Win9x, slide/fade for Win2K+, depends on settings)
  );

  // The trees need an own hint window class because of Unicode output and adjusted font.
  TVirtualTreeHintWindow = class(THintWindow)
  private
    FHintData: TVTHintData;
    FBackground,
    FDrawBuffer,
    FTarget: TBitmap;
    FTextHeight: Integer;
    function AnimationCallback(Step, StepSize: Integer; Data: Pointer): Boolean;
    procedure InternalPaint(Step, StepSize: Integer);
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMNCPaint(var Message: TMessage); message WM_NCPAINT;
  protected
    procedure CreateParams(var Params: TCreateParams); override;

    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure ActivateHint(Rect: TRect; const AHint: string); override;
    function CalcHintRect(MaxWidth: Integer; const AHint: string; AData: Pointer): TRect; override;
    function IsHintMsg(var Msg: TMsg): Boolean; override;
  end;

  // Drag image support for the tree.
  TVTTransparency = 0..255;
  TVTBias = -128..127;

  // Simple move limitation for the drag image.
  TVTDragMoveRestriction = (
    dmrNone,
    dmrHorizontalOnly,
    dmrVerticalOnly
  );

  TVTDragImageStates = set of (
    disHidden,          // Internal drag image is currently hidden (always hidden if drag image helper interfaces are used).
    disInDrag,          // Drag image class is currently being used.
    disPrepared,        // Drag image class is prepared.
    disSystemSupport    // Running on Windows 2000 or higher. System supports drag images natively.
  );

  // Class to manage header and tree drag image during a drag'n drop operation.
  TVTDragImage = class
  private
    FOwner: TBaseVirtualTree;
    FBackImage,                        // backup of overwritten screen area
    FAlphaImage,                       // target for alpha blending
    FDragImage: TBitmap;               // the actual drag image to blend to screen
    FImagePosition,                    // position of image (upper left corner) in screen coordinates
    FLastPosition: TPoint;             // last mouse position in screen coordinates
    FTransparency: TVTTransparency;    // alpha value of the drag image (0 - fully transparent, 255 - fully opaque)
    FPreBlendBias,                     // value to darken or lighten the drag image before it is blended
    FPostBlendBias: TVTBias;           // value to darken or lighten the alpha blend result
    FFade: Boolean;                    // determines whether to fade the drag image from center to borders or not
    FRestriction: TVTDragMoveRestriction;  // determines in which directions the drag image can be moved
    FColorKey: TColor;                 // color to make fully transparent regardless of any other setting
    FStates: TVTDragImageStates;       // Determines the states of the drag image class.
    function GetVisible: Boolean;      // True if the drag image is currently hidden (used only when dragging)
  protected
    procedure InternalShowDragImage(ScreenDC: HDC);
    procedure MakeAlphaChannel(Source, Target: TBitmap);
  public
    constructor Create(AOwner: TBaseVirtualTree);
    destructor Destroy; override;

    function DragTo(P: TPoint; ForceRepaint: Boolean): Boolean;
    procedure EndDrag;
    function GetDragImageRect: TRect;
    procedure HideDragImage;
    procedure PrepareDrag(DragImage: TBitmap; ImagePosition, HotSpot: TPoint; const DataObject: IDataObject);
    procedure RecaptureBackground(Tree: TBaseVirtualTree; R: TRect; VisibleRegion: HRGN; CaptureNCArea,
      ReshowDragImage: Boolean);
    procedure ShowDragImage;
    function WillMove(P: TPoint): Boolean;

    property ColorKey: TColor read FColorKey write FColorKey default clWindow;
    property Fade: Boolean read FFade write FFade default False;
    property MoveRestriction: TVTDragMoveRestriction read FRestriction write FRestriction default dmrNone;
    property PostBlendBias: TVTBias read FPostBlendBias write FPostBlendBias default 0;
    property PreBlendBias: TVTBias read FPreBlendBias write FPreBlendBias default 0;
    property Transparency: TVTTransparency read FTransparency write FTransparency default 128;
    property Visible: Boolean read GetVisible;
  end;
  
  // tree columns implementation
  TVirtualTreeColumns = class;
  TVTHeader = class;

  TVirtualTreeColumnStyle = (
    vsText,
    vsOwnerDraw
  );

  {$ifndef COMPILER_5_UP}
    TImageIndex = Integer;
  {$endif COMPILER_5_UP}

  TVTHeaderColumnLayout = (
    blGlyphLeft,
    blGlyphRight,
    blGlyphTop,
    blGlyphBottom
  );

  TColumnIndex = type Integer;
  TColumnPosition = type Cardinal;

  TVirtualTreeColumn = class(TCollectionItem)
  private
    FText,
    FHint: WideString;
    FLeft,
    FWidth: Integer;
    FPosition: TColumnPosition;
    FMinWidth: Integer;
    FMaxWidth: Integer;
    FStyle: TVirtualTreeColumnStyle;
    FImageIndex: TImageIndex;
    FBiDiMode: TBiDiMode;
    FLayout: TVTHeaderColumnLayout;
    FMargin,
    FSpacing: Integer;
    FOptions: TVTColumnOptions;
    FTag: Integer;
    FAlignment: TAlignment;
    FLastWidth: Integer;
    FColor: TColor;
    function GetLeft: Integer;
    function IsBiDiModeStored: Boolean;
    function IsColorStored: Boolean;
    procedure SetAlignment(const Value: TAlignment);
    procedure SetBiDiMode(Value: TBiDiMode);
    procedure SetColor(const Value: TColor);
    procedure SetImageIndex(Value: TImageIndex);
    procedure SetLayout(Value: TVTHeaderColumnLayout);
    procedure SetMargin(Value: Integer);
    procedure SetMaxWidth(Value: Integer);
    procedure SetMinWidth(Value: Integer);
    procedure SetOptions(Value: TVTColumnOptions);
    procedure SetPosition(Value: TColumnPosition);
    procedure SetSpacing(Value: Integer);
    procedure SetStyle(Value: TVirtualTreeColumnStyle);
    procedure SetText(const Value: WideString);
    procedure SetWidth(Value: Integer);
  protected
    procedure ComputeHeaderLayout(DC: HDC; const Client: TRect; UseHeaderGlyph, UseSortGlyph: Boolean;
      var HeaderGlyphPos, SortGlyphPos: TPoint; var TextBounds: TRect);
    procedure DefineProperties(Filer: TFiler); override;
    procedure GetAbsoluteBounds(var Left, Right: Integer);
    function GetDisplayName: string; override;
    function GetOwner: TVirtualTreeColumns; reintroduce;
    procedure ReadHint(Reader: TReader);
    procedure ReadText(Reader: TReader);
    procedure WriteHint(Writer: TWriter);
    procedure WriteText(Writer: TWriter);
  public
    constructor Create(Collection: TCollection); override;

    procedure Assign(Source: TPersistent); override;
    function GetRect: TRect;
    procedure LoadFromStream(const Stream: TStream; Version: Integer);
    procedure ParentBiDiModeChanged;
    procedure ParentColorChanged;
    procedure RestoreLastWidth;
    procedure SaveToStream(const Stream: TStream);
    function UseRightToLeftReading: Boolean;

    property Left: Integer read GetLeft;
    property Owner: TVirtualTreeColumns read GetOwner;
  published
    property Alignment: TAlignment read FAlignment write SetAlignment;
    property BiDiMode: TBiDiMode read FBiDiMode write SetBiDiMode stored IsBiDiModeStored;
    property Color: TColor read FColor write SetColor stored IsColorStored;
    property Hint: WideString read FHint write FHint stored False;
    property ImageIndex: TImageIndex read FImageIndex write SetImageIndex;
    property Layout: TVTHeaderColumnLayout read FLayout write SetLayout;
    property Margin: Integer read FMargin write SetMargin default 4;
    property MaxWidth: Integer read FMaxWidth write SetMaxWidth default 10000;
    property MinWidth: Integer read FMinWidth write SetMinWidth default 10;
    property Options: TVTColumnOptions read FOptions write SetOptions default DefaultColumnOptions;
    property Position: TColumnPosition read FPosition write SetPosition;
    property Spacing: Integer read FSpacing write SetSpacing default 4;
    property Style: TVirtualTreeColumnStyle read FStyle write SetStyle default vsText;
    property Tag: Integer read FTag write FTag default 0;
    property Text: WideString read FText write SetText stored False; // Never let the VCL store the wide string,
                                                                     // it is simply unable to write it correctly.
                                                                     // We use DefineProperties here.
    property Width: Integer read FWidth write SetWidth;
  end;

  TVirtualTreeColumnClass = class of TVirtualTreeColumn;

  TColumnsArray = array of TVirtualTreeColumn;
  TCardinalArray = array of Cardinal;
  TIndexArray = array of TColumnIndex;

  TVirtualTreeColumns = class(TCollection)
  private
    FHeader: TVTHeader;
    FHeaderBitmap: TBitmap;               // backbuffer for drawing
    FHeaderTheme: HTHEME;                 // The theme handle if the application is themed (Windows XP+ only).
    FHoverIndex,                          // currently "hot" column
    FDownIndex,                           // column on which a mouse button is held down
    FTrackIndex: TColumnIndex;            // index of column which is currently being resized
    FClickIndex: TColumnIndex;            // last clicked column
    FPositionToIndex: TIndexArray;

    // drag support
    FDragIndex: TColumnIndex;             // index of column currently being dragged
    FDropTarget: TColumnIndex;            // current target column (index) while dragging
    FDropBefore: Boolean;                 // True if drop position is in the left half of a column, False for the right
                                          // side to drop the dragged column to
    procedure DrawButtonText(DC: HDC; Caption: WideString; Bounds: TRect; Enabled, Hot: Boolean; DrawFormat: Cardinal);
    function GetItem(Index: TColumnIndex): TVirtualTreeColumn;
    function GetNewIndex(P: TPoint; var OldIndex: TColumnIndex): Boolean;
    procedure SetItem(Index: TColumnIndex; Value: TVirtualTreeColumn);
  protected
    procedure AdjustAutoSize(CurrentIndex: TColumnIndex; Force: Boolean = False);
    function AdjustDownColumn(P: TPoint): TColumnIndex;
    function AdjustHoverColumn(P: TPoint): Boolean;
    procedure AdjustPosition(Column: TVirtualTreeColumn; Position: Cardinal);
    procedure AnimatedResize(Column: Integer; NewWidth: Integer);
    function GetColumnAndBounds(P: TPoint; var ColumnLeft, ColumnRight: Integer; Relative: Boolean = True): Integer;
    function GetOwner: TPersistent; override;
    procedure HandleClick(P: TPoint; Button: TMouseButton; Force: Boolean);
    procedure InitializePositionArray;
    procedure Update(Item: TCollectionItem); override;
    procedure UpdatePositions(Force: Boolean = False);
  public
    constructor Create(AOwner: TVTHeader);
    destructor Destroy; override;

    function Add: TVirtualTreeColumn;
    procedure Assign(Source: TPersistent); override;
    function ColumnFromPosition(P: TPoint; Relative: Boolean = True): TColumnIndex; overload;
    function ColumnFromPosition(PositionIndex: TColumnPosition): TColumnIndex; overload;
    procedure FreeTheme;
    procedure GetColumnBounds(Column: TColumnIndex; var Left, Right: Integer);
    function GetFirstVisibleColumn: TColumnIndex;
    function GetLastVisibleColumn: TColumnIndex;
    function GetNextColumn(Column: TColumnIndex): TColumnIndex;
    function GetNextVisibleColumn(Column: TColumnIndex): TColumnIndex;
    function GetPreviousColumn(Column: TColumnIndex): TColumnIndex;
    function GetPreviousVisibleColumn(Column: TColumnIndex): TColumnIndex;
    function GetVisibleColumns: TColumnsArray;
    function IsValidColumn(Column: TColumnIndex): Boolean;
    procedure LoadFromStream(const Stream: TStream; Version: Integer);
    procedure PaintHeader(DC: HDC; R: TRect; HOffset: Integer);
    procedure SaveToStream(const Stream: TStream);
    function TotalWidth: Integer;
    procedure UpdateTheme(Window: HWND);

    property ClickIndex: TColumnIndex read FClickIndex;
    property Items[Index: TColumnIndex]: TVirtualTreeColumn read GetItem write SetItem; default;
    property Header: TVTHeader read FHeader;
  end;

  TVTHeaderStyle = (
    hsThickButtons,    // TButton look and feel
    hsFlatButtons,     // flatter look than hsThickButton, like an always raised flat TToolButton
    hsPlates,          // flat TToolButton look and feel (raise on hover etc.)
    hsXPStyle          // Windows XP style
  );

  TVTHeaderOption = (
    hoAutoResize,      // adjust a column so that the header never exceeds client width of owner control
    hoColumnResize,    // resizing columns is allowed
    hoDblClickResize,  // allows a column to resize itself to its largest entry
    hoDrag,            // dragging columns is allowed
    hoHotTrack,        // header captions are highlighted when mouse is over a particular column
    hoOwnerDraw,       // header items with the owner draw style can be drawn by the application via event
    hoRestrictDrag,    // header can only be dragged horizontally
    hoShowHint,        // show application defined header hint
    hoShowImages,      // show images
    hoShowSortGlyphs,  // allow visible sort glyphs
    hoVisible          // header is visible
  );
  TVTHeaderOptions = set of TVTHeaderOption;

  THeaderState = (
    hsAutoSizing,      // auto size chain is in progess, do not trigger again on WM_SIZE
    hsDragging,        // header dragging is in progress (only if enabled)
    hsDragPending,     // left button is down, user might want to start dragging a column
    hsLoading,         // The header currently loads from stream, so updates are not necessary.
    hsTracking,        // column resizing is in progress
    hsTrackPending     // left button is down, user might want to start resize a column
  );
  THeaderStates = set of THeaderState;

  TSortDirection = (
    sdAscending,
    sdDescending
  );

  // desribes what made a structure change event happen
  TChangeReason = (
    crIgnore,       // used as placeholder
    crAccumulated,  // used for delayed changes
    crChildAdded,   // one or more child nodes have been added
    crChildDeleted, // one or more child nodes have been deleted
    crNodeAdded,    // a node has been added
    crNodeCopied,   // a node has been duplicated
    crNodeMoved     // a node has been moved to a new place
  );

  TVTHeader = class(TPersistent)
  private
    FOwner: TBaseVirtualTree;
    FColumns: TVirtualTreeColumns;
    FHeight: Cardinal;
    FFont: TFont;
    FOptions: TVTHeaderOptions;
    FStates: THeaderStates;            // used to keep track of internal states the header can enter
    FLeftTrackPos: Integer;            // left border of this column to quickly calculate its width on resize
    FStyle: TVTHeaderStyle;            // button style
    FBackground: TColor;
    FAutoSizeIndex: TColumnIndex;
    FPopupMenu: TPopupMenu;
    FMainColumn: Integer;              // the column which holds the tree
    FImages: TImageList;
    FImageChangeLink: TChangeLink;     // connections to the image list to get notified about changes
    FSortColumn: TColumnIndex;
    FSortDirection: TSortDirection;
    FTrackStart: TPoint;               // client coordinates of the tracking start point
    FDragStart: TPoint;                // initial mouse drag position
    FDragImage: TVTDragImage;          // drag image management during header drag
    function DetermineSplitterIndex(P: TPoint): Boolean;
    procedure FontChanged(Sender: TObject);
    function GetShiftState: TShiftState;
    function GetMainColumn: TColumnIndex;
    function GetUseColumns: Boolean;
    procedure SetAutoSizeIndex(Value: TColumnIndex);
    procedure SetBackground(Value: TColor);
    procedure SetColumns(Value: TVirtualTreeColumns);
    procedure SetFont(const Value: TFont);
    procedure SetHeight(Value: Cardinal);
    procedure SetImages(const Value: TImageList);
    procedure SetMainColumn(Value: TColumnIndex);
    procedure SetOptions(Value: TVTHeaderOptions);
    procedure SetSortColumn(Value: TColumnIndex);
    procedure SetSortDirection(const Value: TSortDirection);
    procedure SetStyle(Value: TVTHeaderStyle);
  protected
    procedure DragTo(P: TPoint);
    function GetOwner: TPersistent; override;
    function HandleHeaderMouseMove(var Message: TWMMouseMove): Boolean;
    function HandleMessage(var Message: TMessage): Boolean;
    procedure ImageListChange(Sender: TObject);
    procedure Invalidate(Column: TVirtualTreeColumn; ExpandToRight: Boolean = False);
    procedure PrepareDrag(P, Start: TPoint);
    procedure RecalculateHeader;
  public
    constructor Create(AOwner: TBaseVirtualTree); virtual;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    procedure AutoFitColumns;
    function InHeader(P: TPoint): Boolean;
    procedure LoadFromStream(const Stream: TStream);
    procedure RestoreColumns;
    procedure SaveToStream(const Stream: TStream);

    property DragImage: TVTDragImage read FDragImage;
    property States: THeaderStates read FStates;
    property Treeview: TBaseVirtualTree read FOwner;
    property UseColumns: Boolean read GetUseColumns;
  published
    property AutoSizeIndex: TColumnIndex read FAutoSizeIndex write SetAutoSizeIndex;
    property Background: TColor read FBackground write SetBackground default clBtnFace;
    property Columns: TVirtualTreeColumns read FColumns write SetColumns;
    property Font: TFont read FFont write SetFont;
    property Height: Cardinal read FHeight write SetHeight default 17;
    property Images: TImageList read FImages write SetImages;
    property MainColumn: TColumnIndex read GetMainColumn write SetMainColumn default 0;
    property Options: TVTHeaderOptions read FOptions write SetOptions default [hoColumnResize, hoDrag, hoShowSortGlyphs];
    property PopupMenu: TPopupMenu read FPopupMenu write FPopUpMenu;
    property SortColumn: TColumnIndex read FSortColumn write SetSortColumn default NoColumn;
    property SortDirection: TSortDirection read FSortDirection write SetSortDirection default sdAscending;
    property Style: TVTHeaderStyle read FStyle write SetStyle;
  end;

  TVTHeaderClass = class of TVTHeader;

  // Communication interface between a tree editor and the tree itself (declared as using stdcall in case it
  // is implemented in a (C/C++) DLL). The GUID is not nessecary in Delphi but important for BCB users
  // to allow QueryInterface and _uuidof calls.
  IVTEditLink = interface
    ['{2BE3EAFA-5ACB-45B4-9D9A-B58BCC496E17}']
    function BeginEdit: Boolean; stdcall;                  // called when editing actually starts
    function CancelEdit: Boolean; stdcall;                 // called when editing has been cancelled by the tree
    function EndEdit: Boolean; stdcall;                    // called when editing has been finished by the tree
    function PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean; stdcall;
                                                           // called after creation to allow a setup
    function GetBounds: TRect; stdcall;                    // called to get the current size of the edit window
                                                           // (only important if the edit resizes itself)
    procedure ProcessMessage(var Message: TMessage); stdcall;
                                                           // used to forward messages to the edit window(s)
    procedure SetBounds(R: TRect); stdcall;                // called to place the editor
  end;

  // Indicates in the OnUpdating event what state the tree is currently in.
  TVTUpdateState = (
    usBegin,       // The tree just entered the update state (BeginUpdate call for the first time).
    usBeginSynch,  // The tree just entered the synch update state (BeginSynch call for the first time).
    usSynch,       // Begin/EndSynch has been called but the tree did not change the update state.
    usUpdate,      // Begin/EndUpdate has been called but the tree did not change the update state.
    usEnd,         // The tree just left the update state (EndUpdate called for the last level).
    usEndSynch     // The tree just left the synch update state (EndSynch called for the last level).
  );

  // Used during owner draw of the header to indicate which drop mark for the column must be drawn.
  TVTDropMarkMode = (
    dmmNone,
    dmmLeft,
    dmmRight
  );

  // node enumeration
  TVTGetNodeProc = procedure(Sender: TBaseVirtualTree; Node: PVirtualNode; Data: Pointer; var Abort: Boolean) of object;

  // node events            
  TVTChangingEvent = procedure(Sender: TBaseVirtualTree; Node: PVirtualNode; var Allowed: Boolean) of object;
  TVTCheckChangingEvent = procedure(Sender: TBaseVirtualTree; Node: PVirtualNode; var NewState: TCheckState;
    var Allowed: Boolean) of object;
  TVTChangeEvent = procedure(Sender: TBaseVirtualTree; Node: PVirtualNode) of object;
  TVTStructureChangeEvent = procedure(Sender: TBaseVirtualTree; Node: PVirtualNode; Reason: TChangeReason) of object;
  TVTEditCancelEvent = procedure(Sender: TBaseVirtualTree; Column: Integer) of object;
  TVTEditChangingEvent = procedure(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: Integer;
    var Allowed: Boolean) of object;
  TVTEditChangeEvent = procedure(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: Integer) of object;
  TVTFreeNodeEvent = procedure(Sender: TBaseVirtualTree; Node: PVirtualNode) of object;
  TVTFocusChangingEvent = procedure(Sender: TBaseVirtualTree; OldNode, NewNode: PVirtualNode; OldColumn,
    NewColumn: Integer; var Allowed: Boolean) of object;
  TVTFocusChangeEvent = procedure(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: Integer) of object;
  TVTGetImageEvent = procedure(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: Integer;
    var Ghosted: Boolean; var ImageIndex: Integer) of object;
  TVTHotNodeChangeEvent = procedure(Sender: TBaseVirtualTree; OldNode, NewNode: PVirtualNode) of object;
  TVTInitChildrenEvent = procedure(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal) of object;
  TVTInitNodeEvent = procedure(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
    var InitialStates: TVirtualNodeInitStates) of object;
  TVTPopupEvent = procedure(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: Integer; const P: TPoint;
    var AskParent: Boolean; var PopupMenu: TPopupMenu) of object;
  TVTHelpContextEvent = procedure(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: Integer;
    var HelpContext: Integer) of object;
  TVTCreateEditorEvent = procedure(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: Integer;
    out EditLink: IVTEditLink) of object;
  TVTSaveNodeEvent = procedure(Sender: TBaseVirtualTree; Node: PVirtualNode; Stream: TStream) of object;

  // header/column events
  TVTHeaderClickEvent = procedure(Sender: TVTHeader; Column: Integer; Button: TMouseButton; Shift: TShiftState; X,
    Y: Integer) of object;
  TVTHeaderMouseEvent = procedure(Sender: TVTHeader; Button: TMouseButton; Shift: TShiftState; X, Y: Integer) of object;
  TVTHeaderMouseMoveEvent = procedure(Sender: TVTHeader; Shift: TShiftState; X, Y: Integer) of object;
  TVTHeaderNotifyEvent = procedure(Sender: TVTHeader; Column: Integer) of object;
  TVTHeaderDraggingEvent = procedure(Sender: TVTHeader; Column: Integer; var Allowed: Boolean) of object;
  TVTHeaderDraggedEvent = procedure(Sender: TVTHeader; Column, OldPosition: Integer) of object;
  TVTHeaderPaintEvent = procedure(Sender: TVTHeader; HeaderCanvas: TCanvas; Column: TVirtualTreeColumn; R: TRect; Hover,
    Pressed: Boolean; DropMark: TVTDropMarkMode) of object;
  TVTColumnClickEvent = procedure (Sender: TBaseVirtualTree; Column: Integer; Shift: TShiftState) of object;
  TVTColumnDblClickEvent = procedure (Sender: TBaseVirtualTree; Column: Integer; Shift: TShiftState) of object;
  TVTGetHeaderCursorEvent = procedure(Sender: TVTHeader; var Cursor: HCURSOR) of object;

  // move and copy events
  TVTNodeMovedEvent = procedure(Sender: TBaseVirtualTree; Node: PVirtualNode) of object;
  TVTNodeMovingEvent = procedure(Sender: TBaseVirtualTree; Node, NewParent: PVirtualNode;
    var Allowed: Boolean) of object;
  TVTNodeCopiedEvent = procedure(Sender: TBaseVirtualTree; Node: PVirtualNode) of object;
  TVTNodeCopyingEvent = procedure(Sender: TBaseVirtualTree; Node, NewParent: PVirtualNode;
    var Allowed: Boolean) of object;

  // drag'n drop/OLE events
  TVTCreateDragManagerEvent = procedure(Sender: TBaseVirtualTree; out DragManager: IVTDragManager) of object;
  TVTCreateDataObjectEvent = procedure(Sender: TBaseVirtualTree; out IDataObject: IDataObject) of object;
  TVTDragAllowedEvent = procedure(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: Integer;
    var Allowed: Boolean) of object;
  TVTDragOverEvent = procedure(Sender: TBaseVirtualTree; Source: TObject; Shift: TShiftState; State: TDragState;
    Pt: TPoint; Mode: TDropMode; var Effect: Integer; var Accept: Boolean) of object;
  TVTDragDropEvent = procedure(Sender: TBaseVirtualTree; Source: TObject; DataObject: IDataObject;
    Formats: TFormatArray; Shift: TShiftState; Pt: TPoint; var Effect: Integer; Mode: TDropMode) of object;
  TVTRenderOLEDataEvent = procedure(Sender: TBaseVirtualTree; const FormatEtcIn: TFormatEtc; out Medium: TStgMedium;
    ForClipboard: Boolean; var Result: HRESULT) of object;
  TVTGetUserClipboardFormatsEvent = procedure(Sender: TBaseVirtualTree; var Formats: TFormatEtcArray) of object;

  // paint events
  TVTBeforeItemEraseEvent = procedure(Sender: TBaseVirtualTree; Canvas: TCanvas; Node: PVirtualNode; ItemRect: TRect;
    var ItemColor: TColor; var EraseAction: TItemEraseAction) of object;
  TVTAfterItemEraseEvent = procedure(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
    ItemRect: TRect) of object;
  TVTBeforeItemPaintEvent = procedure(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
    ItemRect: TRect; var CustomDraw: Boolean) of object;
  TVTAfterItemPaintEvent = procedure(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
    ItemRect: TRect) of object;
  TVTBeforeCellPaintEvent = procedure(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
    Column: Integer; CellRect: TRect) of object;
  TVTAfterCellPaintEvent = procedure(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
    Column: Integer; CellRect: TRect) of object;
  TVTPaintEvent = procedure(Sender: TBaseVirtualTree; TargetCanvas: TCanvas) of object;
  TVTBackgroundPaintEvent = procedure(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; R: TRect;
    var Handled: Boolean) of object;
  TVTGetLineStyleEvent = procedure(Sender: TBaseVirtualTree; var Bits: Pointer) of object;

  // search, sort
  TVTCompareEvent = procedure(Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode; Column: Integer;
    var Result: Integer) of object;
  TVTIncrementalSearchEvent = procedure(Sender: TBaseVirtualTree; Node: PVirtualNode; const SearchText: WideString;
    var Result: Integer) of object;

  // miscellaneous
  TVTGetNodeDataSizeEvent = procedure(Sender: TBaseVirtualTree; var NodeDataSize: Integer) of object;
  TVTKeyActionEvent = procedure(Sender: TBaseVirtualTree; var CharCode: Word; var Shift: TShiftState;
    var DoDefault: Boolean) of object;
  TVTScrollEvent = procedure(Sender: TBaseVirtualTree; DeltaX, DeltaY: Integer) of object;
  TVTUpdatingEvent = procedure(Sender: TBaseVirtualTree; State: TVTUpdateState) of object;
  TVTGetCursorEvent = procedure(Sender: TBaseVirtualTree; var Cursor: TCursor) of object;

  // various events must be handled at different places than they were initiated or need
  // a persistent storage until they are reset
  TVirtualTreeStates = set of (
    tsChangePending,          // a change is pending
    tsCollapsing,             // a full collapse operation is in progress
    tsClearPending,           // need to clear the current selection on next mouse move
    tsClipboardFlushing,      // set during flushing the clipboard to avoid freeing the content
    tsCopyPending,            // indicates a pending copy operation which needs to be finished
    tsCutPending,             // indicates a pending cut operation which needs to be finished
    tsDrawSelPending,         // multiselection only, user held down the left mouse button on a free
                              // area and might want to start draw selection
    tsDrawSelecting,          // multiselection only, draw selection has actually started
    tsEditing,                // indicates that an edit operation is currently in progress
    tsEditPending,            // on mouse up start edit if dragging has not started
    tsExpanding,              // a full expand operation is in progress
    tsHint,                   // set when our hint is visible or soon will be
    tsHintShown,              // indicates that a hint/tooltip (header or node) has been shown at least once (needed for
                              // workaround of a bug/gotcha in the VCL)
    tsInAnimation,            // set if the tree is currently in an animation loop
    tsIncrementalSearching,   // set when the user starts incremental search and reset on timeout
    tsIncrementalSearchPending, // set in WM_KEYDOWN to tell to use the char in WM_CHAR for incremental search
    tsIterating,              // set when IterateSubtree is currently in progress
    tsLeftButtonDown,         // set when the left mouse button is down
    tsMiddleButtonDown,       // set when the middle mouse button is down
    tsNeedRootCountUpdate,    // set if while loading a root node count is set
    tsOLEDragging,            // OLE dragging in progress
    tsOLEDragPending,         // user has requested to start delayed dragging
    tsPainting,               // the tree is currently painting itself
    tsRightButtonDown,        // set when the right mouse button is down
    tsScrolling,              // set when autoscrolling is active
    tsScrollPending,          // set when waiting for the scroll delay time to elapse
    tsSizing,                 // set when the tree window is being resized and is used to prevent recursive calls
                              // due to setting the scrollbars when sizing
    tsStopValidation,         // cache validation can be stopped (usually because a change has occured meanwhile)
    tsStructureChangePending, // the structure of the tree has been changed while the update was locked
    tsSynchMode,              // Set when the tree is in synch mode, where no timer events are triggered.
    tsThumbTracking,          // stop updating the horizontal scroll bar while dragging the vertical thumb and vice versa
    tsUpdating,               // the tree does currently not update its window because a BeginUpdate has not yet ended
    tsUseCache,               // The tree's node caches are validated and non-empty.
    tsUseThemes,              // The tree runs under WinXP+ and themes are enabled.
    tsValidating,             // the tree's node caches are currently validated
    tsValidationNeeded,       // something in the structure of the tree has changed, the cache needs now to be validated
    tsVCLDragging,            // VCL drag'n drop in progress
    tsVCLDragPending,         // one-shot flag to avoid clearing the current selection on implicit mouse up for VCL drag
    tsWheelPanning,           // Wheel mouse panning is active or soon will be.
    tsWheelScrolling,         // Wheel mouse scrolling is active or soon will be.
    tsWindowCreating          // set during window handle creation to avoid frequent unnecessary updates
  );

  // determines whether and how the drag image is to show
  TVTDragImageKind = (
    diComplete,       // show a complete drag image with all columns, only visible columns are shown
    diMainColumnOnly, // show only the main column (the tree column)
    diNoImage         // don't show a drag image at all
  );

  // Switch for OLE and VCL drag'n drop. Because it is not possible to have both simultanously.
  TVTDragType = (
    dtOLE,
    dtVCL
  );

  // options which determine what to draw in PaintTree
  TVTInternalPaintOption = (
    poBackground,       // draw background image if there is any and it is enabled
    poColumnColor,      // erase node's background with the column's color
    poDrawFocusRect,    // draw focus rectangle around the focused node
    poDrawSelection,    // draw selected nodes with the normal selection color
    poDrawDropMark,     // draw drop mark if a node is currently the drop target
    poGridLines,        // draw grid lines if enabled
    poMainOnly,         // draw only the main column
    poSelectedOnly      // draw only selected nodes
  );
  TVTInternalPaintOptions = set of TVTInternalPaintOption;

  // Determines the look of a tree's lines.
  TVTLineStyle = (
    lsCustomStyle,           // application provides a line pattern
    lsDotted,                // usual dotted lines (default)
    lsSolid                  // simple solid lines
  );

  // TVTLineType is used during painting a tree
  TVTLineType = (
    ltNone,          // no line at all
    ltBottomRight,   // a line from bottom to the center and from there to the right
    ltTopDown,       // a line from top to bottom
    ltTopDownRight,  // a line from top to bottom and from center to the right
    ltRight,         // a line from center to the right
    ltTopRight,      // a line from bottom to center and from there to the right
    // special styles for alternative drawings of tree lines
    ltLeft,          // a line from top to bottom at the left
    ltLeftBottom     // a combination of ltLeft and a line at the bottom from left to right
  );

  // Determines how to draw tree lines.
  TVTLineMode = (
    lmNormal,        // usual tree lines (as in TTreeview)
    lmBands          // looks similar to a Nassi-Schneidermann diagram
  );

  // A collection of line type IDs which is used while painting a node.
  TLineImage = array of TVTLineType;

  TVTScrollIncrement = 1..10000;
  
  // A class to manage scroll bar aspects.
  TScrollBarOptions = class(TPersistent)
  private
    FAlwaysVisible: Boolean;
    FOwner: TBaseVirtualTree;
    FScrollBars: TScrollStyle;                   // used to hide or show vertical and/or horizontal scrollbar
    FScrollBarStyle: TScrollBarStyle;            // kind of scrollbars to use
    FIncrementX,
    FIncrementY: TVTScrollIncrement;             // number of pixels to scroll in one step (when auto scrolling)
    procedure SetAlwaysVisible(Value: Boolean);
    procedure SetScrollBars(Value: TScrollStyle);
    procedure SetScrollBarStyle(Value: TScrollBarStyle);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TBaseVirtualTree);
  published
    property AlwaysVisible: Boolean read FAlwaysVisible write SetAlwaysVisible default False;
    property HorizontalIncrement: TVTScrollIncrement read FIncrementX write FIncrementX default 20;
    property ScrollBars: TScrollStyle read FScrollbars write SetScrollBars default ssBoth;
    property ScrollBarStyle: TScrollBarStyle read FScrollBarStyle write SetScrollBarStyle default sbmRegular;
    property VerticalIncrement: TVTScrollIncrement read FIncrementY write FIncrementY default 20;
  end;

  // class to collect all switchable colors into one place
  TVTColors = class(TPersistent)
  private
    FOwner: TBaseVirtualTree;
    FColors: array[0..13] of TColor;
    function GetColor(const Index: Integer): TColor;
    procedure SetColor(const Index: Integer; const Value: TColor);
  public
    constructor Create(AOwner: TBaseVirtualTree);

    procedure Assign(Source: TPersistent); override;
  published
    property BorderColor: TColor index 7 read GetColor write SetColor default clBtnFace;
    property DisabledColor: TColor index 0 read GetColor write SetColor default clBtnShadow;
    property DropMarkColor: TColor index 1 read GetColor write SetColor default clHighlight;
    property DropTargetColor: TColor index 2 read GetColor write SetColor default clHighLight;
    property DropTargetBorderColor: TColor index 11 read GetColor write SetColor default clHighLight;
    property FocusedSelectionColor: TColor index 3 read GetColor write SetColor default clHighLight;
    property FocusedSelectionBorderColor: TColor index 9 read GetColor write SetColor default clHighLight;
    property GridLineColor: TColor index 4 read GetColor write SetColor default clBtnFace;
    property HotColor: TColor index 8 read GetColor write SetColor default clWindowText;
    property SelectionRectangleBlendColor: TColor index 12 read GetColor write SetColor default clHighlight;
    property SelectionRectangleBorderColor: TColor index 13 read GetColor write SetColor default clHighlight;
    property TreeLineColor: TColor index 5 read GetColor write SetColor default clBtnShadow;
    property UnfocusedSelectionColor: TColor index 6 read GetColor write SetColor default clBtnFace;
    property UnfocusedSelectionBorderColor: TColor index 10 read GetColor write SetColor default clBtnFace;
  end;

  // For painting a node and its columns/cells a lot of information must be passed frequently to
  // the paint methode.
  TVTImageInfo = record
    Index: Integer;          // index in the associated image list
    XPos,                    // horizontal position in the current target canvas
    YPos: Integer;           // vertical position in the current target canvas
    Ghosted: Boolean;        // flag to indicate that the image must be drawn slightly lighter
  end;

  TVTImageInfoIndex = (
    iiNormal,
    iiState,
    iiCheck
  );

  // Options which are used when modifying the scroll offsets.
  TScrollUpdateOptions = set of (
    suoRepaintHeader,        // if suoUpdateNCArea is also set then invalidate the header
    suoRepaintScrollbars,    // if suoUpdateNCArea is also set then repaint both scrollbars after updating them
    suoScrollClientArea,     // scroll and invalidate the proper part of the client area
    suoUpdateNCArea          // update non-client area (scrollbars, header)
  );

  // Determines the look of a tree's buttons.
  TVTButtonStyle = (
    bsRectangle,             // traditional Windows look (plus/minus buttons)
    bsTriangle               // traditional Macintosh look
  );

  // TButtonFillMode is only used when the button style is bsRectangle and determines how to fill the interior.
  TVTButtonFillMode = (
    fmTreeColor,             // solid color, uses the tree's background color
    fmWindowColor,           // solid color, uses clWindow
    fmShaded,                // color gradient, Windows XP style (legacy code, use toThemeAware on Windows XP instead)
    fmTransparent            // transparent color, use the item's background color
  );

  TVTPaintInfo = record
    Canvas: TCanvas;           // the canvas to paint on
    PaintOptions: TVTInternalPaintOptions;  // a copy of the paint options passed to PaintTree
    Node: PVirtualNode;        // the node to paint
    Column: TColumnIndex;      // the node's column index to paint
    Position: TColumnPosition; // the column position of the node
    CellRect,                  // the node cell
    ContentRect: TRect;        // the area of the cell used for the node's content
    NodeWidth: Integer;        // the actual node width
    Alignment: TAlignment;     // how to align within the node rectangle
    BidiMode: TBidiMode;       // directionality to be used for painting
    BrushOrigin: TPoint;       // the alignment for the brush used to draw dotted lines
    ImageInfo: array[TVTImageInfoIndex] of TVTImageInfo; // info about each possible node image
  end;

  // Method called by the Animate routine for each animation step. 
  TVTAnimationCallback = function(Step, StepSize: Integer; Data: Pointer): Boolean of object;

  TVTIncrementalSearch = (
    isAll,                   // search every node in tree, initialize if necessary
    isNone,                  // disable incremental search
    isInitializedOnly,       // search only initialized nodes, skip others
    isVisibleOnly            // search only visible nodes, initialize if necessary
  );

  // Determines which direction to use when advancing nodes during an incremental search.
  TVTSearchDirection = (
    sdForward,
    sdBackward
  );

  // Determines where to start incremental searching for each key press.
  TVTSearchStart = (
    ssAlwaysStartOver,       // always use the first/last node (depending on direction) to search from
    ssLastHit,               // use the last found node
    ssFocusedNode            // use the currently focused node
  );

  // Determines how to use the align member of a node.
  TVTNodeAlignment = (
    naFromBottom,            // the align member specifies amount of units (usually pixels) from top border of the node
    naFromTop,               // align is to be measured from bottom
    naProportional           // align is to be measure in percent of the entire node height and relative to top
  );

  // Determines how to draw the selection rectangle used for draw selection.
  TVTDrawSelectionMode = (
    smDottedRectangle,       // same as DrawFocusRect
    smBlendedRectangle       // alpha blending, uses special colors (see TVTColors)
  );

  TClipboardFormats = class(TStringList)
  private
    FOwner: TBaseVirtualTree;
  public
    constructor Create(AOwner: TBaseVirtualTree); virtual;

    function Add(const S: string): Integer; override;
    procedure Insert(Index: Integer; const S: string); override;
    property Owner: TBaseVirtualTree read FOwner;
  end;

  // Helper types for node iterations.
  TGetFirstNodeProc = function: PVirtualNode of object;
  TGetNextNodeProc = function(Node: PVirtualNode): PVirtualNode of object;

  // ----- TBaseVirtualTree
  TBaseVirtualTree = class(TCustomControl)
  private
    FBorderStyle: TBorderStyle;
    FHeader: TVTHeader;
    FRoot: PVirtualNode;
    FDefaultNodeHeight,
    FIndent: Cardinal;
    FOptions: TCustomVirtualTreeOptions;
    FUpdateCount: Cardinal;                      // update stopper, updates of the tree control are only done if = 0
    FSynchUpdateCount: Cardinal;                 // synchronizer, causes all events which are usually done via timers
                                                 // to happen immediately, regardless of the normal update state
    FNodeDataSize: Integer;                      // number of bytes to allocate with each node (in addition to its base
                                                 // structure and the internal data), if -1 then do callback
    FStates: TVirtualTreeStates;                 // various active/pending states the tree needs to consider
    FLastSelected,
    FFocusedNode: PVirtualNode;
    FEditColumn,                                 // column to be edited (focused node)
    FFocusedColumn: Integer;                     // -1 if no columns are active otherwise the last hit column of the
                                                 // currently focused node
    FScrollDirections: TScrollDirections;        // directions to scroll client area into depending on mouse position
    FLastStructureChangeReason: TChangeReason;   // used for delayed structur change event
    FLastStructureChangeNode,                    // dito
    FLastChangedNode,                            // used for delayed change event
    FCurrentHotNode,                             // node over which the mouse is hovering
    FLastVCLDragTarget: PVirtualNode;            // just a cache for VCL drag'n drop (keyword: DragLeave on DragDrop)
    FLastSelRect,
    FNewSelRect: TRect;                          // used while doing draw selection
    FHotCursor: TCursor;                         // can be set to additionally indicate the current hot node
    FAnimationType: THintAnimationType;          // none, fade in, slide in animation (just like those animations used
                                                 // in Win98 (slide) and Windows 2000 (fade))
    FHintMode: TVTHintMode;                      // determines the kind of the hint window
    FHintData: TVTHintData;                      // used while preparing the hint window
    FChangeDelay: Cardinal;                      // used to delay OnChange event
    FEditDelay: Cardinal;                        // determines time to elapse before a node goes into edit mode
    FPositionCache: TCache;                      // array which stores node references ordered by vertical positions
                                                 // (see also DoValidateCache for more information)
    FVisibleCount: Cardinal;                     // number of currently visible nodes
    FStartIndex: Cardinal;                       // index to start validating cache from
    FSelection: TNodeArray;                      // list of currently selected nodes
    FSelectionCount: Integer;                    // number of currently selected nodes (size of FSelection might differ)
    FRangeAnchor: PVirtualNode;                  // anchor node for selection with the keyboard, determines start of a
                                                 // selection range
    FCheckNode: PVirtualNode;                    // node which "captures" an check event
    FPendingCheckState: TCheckState;             // the new state the check node will get if all wents fine
    FLastSelectionLevel: Integer;                // keeps the last node level for constrained multiselection
    FDrawSelShiftState: TShiftState;             // keeps the initial shift state when the user starts selection with
                                                 // the mouse
    FEditLink: IVTEditLink;                      // used to comunicate with an application defined editor
    FTempNodeCache: TNodeArray;                  // used at various places to hold temporarily a bunch of node refs.
    FTempNodeCount: Cardinal;                    // number of nodes in FTempNodeCache
    FBackground: TPicture;                       // a background image loadable at design time
    FMargin: Integer;                            // horizontal border distance
    FTextMargin: Integer;                        // space between the node's text and its horizontal bounds
    FBackgroundOffsetX,
    FBackgroundOffsetY: Integer;                 // used to fine tune the position of the background image
    FAnimationDuration: Cardinal;                // specifies how long an animation shall take (expanding, hint)
    FWantTabs: Boolean;                          // If True then the tree also consumes the tab key.
    FNodeAlignment: TVTNodeAlignment;            // determines how to interpret the align member of a node
    FHeaderRect: TRect;                          // Space which the header currently uses in the control (window coords). 

    // paint support and images
    FPlusBM,
    FMinusBM: TBitmap;                           // small bitmaps used for tree buttons
    FImages,                                     // normal images in the tree
    FStateImages,                                // state images in the tree
    FCustomCheckImages: TImageList;              // application defined check images
    FCheckImageKind: TCheckImageKind;            // light or dark, cross marks or tick marks
    FCheckImages: TImageList;                    // reference to global image list to be used for the check images
    FImageChangeLink,
    FStateChangeLink,
    FCustomCheckChangeLink: TChangeLink;         // connections to the image lists
    FOldFontChange: TNotifyEvent;                // helper method pointer for tracking font changes in the off screen buffer
    FFontChanged: Boolean;                       // flag for keeping informed about font changes in the off screen buffer
    FColors: TVTColors;                          // class comprising all customizable colors in the tree
    FButtonStyle: TVTButtonStyle;                // style of the tree buttons
    FButtonFillMode: TVTButtonFillMode;          // for rectangular tree buttons only: how to fill them
    FLineStyle: TVTLineStyle;                    // style of the tree lines
    FLineMode: TVTLineMode;                      // tree lines or bands etc.
    FDottedBrush: HBRUSH;                        // used to paint dotted lines without special pens
    FSelectionCurveRadius: Cardinal;             // radius for rounded selection rectangles
    FDrawSelectionMode: TVTDrawSelectionMode;    // determines the paint mode for draw selection

    // alignment and directionality support
    FAlignment: TAlignment;                      // default alignment of the tree if no columns are shown

    // drag'n drop and clipboard support
    FDragImageKind: TVTDragImageKind;            // determines whether or not and what to show in the drag image
    FDragOperations: TDragOperations;            // determines which operations are allowed during drag'n drop
    FDragThreshold: Integer;                     // used to determine when to actually start a drag'n drop operation
    FDragManager: IVTDragManager;                // drag'n drop, cut'n paste
    FDropTargetNode: PVirtualNode;               // node currently selected as drop target
    FLastDropMode: TDropMode;                    // set while dragging and used to track changes
    FDragSelection: TNodeArray;                  // temporary copy of FSelection used during drag'n drop
    FDragType: TVTDragType;                      // used to switch between OLE and VCL drag'n drop
    FDragImage: TVTDragImage;                    // drag image management
    FDragWidth,
    FDragHeight: Integer;                        // size of the drag image, the larger the more CPU power is needed
    FClipboardFormats: TClipboardFormats;        // a list of clipboard format descriptions enabled for this tree

    // scroll support
    FScrollBarOptions: TScrollBarOptions;        // common properties of horizontal and vertical scrollbar
    FAutoScrollInterval: TAutoScrollInterval;    // determines speed of auto scrolling
    FAutoScrollDelay: Cardinal;                  // amount of milliseconds to wait until autoscrolling becomes active
    FAutoExpandDelay: Cardinal;                  // amount of milliseconds to wait until a node is expanded if it is the
                                                 // drop target
    FOffsetX,
    FOffsetY: Integer;                           // determines left and top scroll offset
    FRangeX,
    FRangeY: Cardinal;                           // current virtual width and height of the tree

    FDefaultPasteMode: TVTNodeAttachMode;        // used to determine where to add pasted nodes to
    FSingletonNodeArray: TNodeArray;             // contains only one element for quick addition of single nodes
                                                 // to the selection
    FDragScrollStart: Cardinal;                  // contains the start time when a tree does auto scrolling as drop target

    // search
    FIncrementalSearch: TVTIncrementalSearch;    // used to determine whether and how incremental search is to be used
    FSearchTimeout: Cardinal;                    // number of milliseconds after which to stop incremental searching
    FSearchBuffer: WideString;                   // collects a sequence of keypresses used to do incremental searching
    FLastSearchNode: PVirtualNode;               // reference to node which was last found as search fit
    FSearchDirection: TVTSearchDirection;        // direction to incrementally search the tree
    FSearchStart: TVTSearchStart;                // where to start iteration on each key press

    // themes
    FTreeTheme: HTHEME;                          // Handle to the tree part of the current theme (if running on WinXP).
    FButtonTheme: HTHEME;                        // Handle to the button part of the current theme.
    
    // miscellanous
    FTotalInternalDataSize: Cardinal;            // Cache of the sum of the necessary internal data size for all tree
                                                 // classes derived from this base class.
    FPanningWindow: HWND;                        // Helper window for wheel panning
    FPanningCursor: HCURSOR;                     // Current wheel panning cursor.
    FPanningImage: TBitmap;                      // A little 32x32 bitmap to indicate the panning reference point.
    FLastClickPos: TPoint;                       // Used for retained drag start and wheel mouse scrolling.

    // common events
    FOnChange: TVTChangeEvent;                   // selection change
    FOnStructureChange: TVTStructureChangeEvent; // structural change like adding nodes etc.
    FOnInitChildren: TVTInitChildrenEvent;       // called when a node's children are needed (expanding etc.)
    FOnInitNode: TVTInitNodeEvent;               // called when a node needs to be initialized (child count etc.)
    FOnFreeNode: TVTFreeNodeEvent;               // called when a node is about to be destroyed, user data can and should
                                                 // be freed in this event
    FOnGetImage: TVTGetImageEvent;               // used to retrieve the image index of a given node
    FOnHotChange: TVTHotNodeChangeEvent;         // called when the current "hot" node (that is, the node under the mouse)
                                                 // changes and hot tracking is enabled
    FOnExpanding,                                // called just before a node is expanded
    FOnCollapsing: TVTChangingEvent;             // called just before a node is collapsed
    FOnChecking: TVTCheckChangingEvent;          // called just before a node's check state is changed
    FOnExpanded,                                 // called after a node has been expanded
    FOnCollapsed,                                // called after a node has been collapsed
    FOnChecked: TVTChangeEvent;                  // called after a node's check state has been changed
    FOnResetNode: TVTChangeEvent;                // called when a node is set to be uninitialized
    FOnNodeMoving: TVTNodeMovingEvent;           // called just before a node is moved from one parent node to another
                                                 // (this can be cancelled)
    FOnNodeMoved: TVTNodeMovedEvent;             // called after a node and its children have been moved to another
                                                 // parent node (probably another tree, but within the same application)
    FOnNodeCopying: TVTNodeCopyingEvent;         // called when an node is copied to another parent node (probably in
                                                 // another tree, but within the same application, can be cancelled)
    FOnNodeCopied: TVTNodeCopiedEvent;           // call after a node has been copied
    FOnEditing: TVTEditChangingEvent;            // called just before a node goes into edit mode
    FOnEditCancelled: TVTEditCancelEvent;        // called when editing has been cancelled
    FOnEdited: TVTEditChangeEvent;               // called when editing has successfully been finished
    FOnFocusChanging: TVTFocusChangingEvent;     // called when the focus is about to go to a new node and/or column
                                                 // (can be cancelled)
    FOnFocusChanged: TVTFocusChangeEvent;        // called when the focus goes to a new node and/or column
    FOnGetPopupMenu: TVTPopupEvent;              // called when the popup for a node needs to be shown
    FOnGetHelpContext: TVTHelpContextEvent;      // called when a node specific help theme should be called
    FOnCreateEditor: TVTCreateEditorEvent;       // called when a node goes into edit mode, this allows applications
                                                 // to supply their own editor
    FOnLoadNode,                                 // called after a node has been loaded from a stream (file, clipboard,
                                                 // OLE drag'n drop) to allow an application to load their own data
                                                 // saved in OnSaveNode
    FOnSaveNode: TVTSaveNodeEvent;               // called when a node needs to be serialized into a stream
                                                 // (see OnLoadNode) to give the application the opportunity to save
                                                 // their node specific, persistent data (note: never save memory
                                                 // references)

    // header/column mouse events
    FOnHeaderClick,                              // mouse events for the header, just like those for a control
    FOnHeaderDblClick: TVTHeaderClickEvent;
    FOnHeaderMouseDown,
    FOnHeaderMouseUp: TVTHeaderMouseEvent;
    FOnHeaderMouseMove: TVTHeaderMouseMoveEvent;
    FOnColumnClick: TVTColumnClickEvent;
    FOnColumnDblClick: TVTColumnDblClickEvent;
    FOnColumnResize: TVTHeaderNotifyEvent;
    FOnGetHeaderCursor: TVTGetHeaderCursorEvent; // triggered to allow the app. to use customized cursors for the header

    // paint events
    FOnAfterPaint,                               // triggered when the tree has entirely been painted
    FOnBeforePaint: TVTPaintEvent;               // triggered when the tree is about to be painted
    FOnAfterItemPaint: TVTAfterItemPaintEvent;   // triggered after an item has been painted
    FOnBeforeItemPaint: TVTBeforeItemPaintEvent; // triggered when an item is about to be painted
    FOnBeforeItemErase: TVTBeforeItemEraseEvent; // triggered when an item's background is about to be erased
    FOnAfterItemErase: TVTAfterItemEraseEvent;   // triggered after an item's background has been erased
    FOnAfterCellPaint: TVTAfterCellPaintEvent;   // triggered after a column of an item has been painted
    FOnBeforeCellPaint: TVTBeforeCellPaintEvent; // triggered when a column of an item is about to be painted
    FOnHeaderDraw: TVTHeaderPaintEvent;          // used when owner draw is enabled for the header and a column is set
                                                 // to owner draw mode
    FOnGetLineStyle: TVTGetLineStyleEvent;       // triggered when a custom line style is used and the pattern brush
                                                 // needs to be build
    FOnPaintBackground: TVTBackgroundPaintEvent; // triggered if a part of the tree's background must be erased which is
                                                 // not covered by any node

    // drag'n drop events
    FOnCreateDragManager: TVTCreateDragManagerEvent; // called to allow for app./descentant defined drag managers
    FOnCreateDataObject: TVTCreateDataObjectEvent; // called to allow for app./descentant defined data objects
    FOnDragAllowed: TVTDragAllowedEvent;         // used to get permission for manual drag in mouse down
    FOnDragOver: TVTDragOverEvent;               // called for every mouse move
    FOnDragDrop: TVTDragDropEvent;               // called on release of mouse button (if drop was allowed)
    FOnHeaderDragged: TVTHeaderDraggedEvent;     // header (column) drag'n drop
    FOnHeaderDragging: TVTHeaderDraggingEvent;   // header (column) drag'n drop
    FOnRenderOLEData: TVTRenderOLEDataEvent;     // application/descentant defined clipboard formats
    FOnGetUserClipboardFormats: TVTGetUserClipboardFormatsEvent; // gives application/descentants the opportunity to
                                                 // add own clipboard formats on the fly

    // miscellanous events
    FOnGetNodeDataSize: TVTGetNodeDataSizeEvent; // called if NodeDataSize is -1
    FOnKeyAction: TVTKeyActionEvent;             // used to selectively prevent key actions (full expand on Ctrl+'+' etc.)
    FOnScroll: TVTScrollEvent;                   // called when one or both paint offsets changed
    FOnUpdating: TVTUpdatingEvent;               // called from BeginUpdate, EndUpdate, BeginSynch and EndSynch
    FOnGetCursor: TVTGetCursorEvent;             // called to allow the app. to set individual cursors

    // search, sort
    FOnCompareNodes: TVTCompareEvent;            // used during sort
    FOnIncrementalSearch: TVTIncrementalSearchEvent; // triggered on every key press (not key down)

    procedure AdjustCoordinatesByIndent(var PaintInfo: TVTPaintInfo; Indent: Integer);
    procedure AdjustImageBorder(Images: TImageList; BidiMode: TBidiMode; VAlign: Integer; var R: TRect;
      var ImageInfo: TVTImageInfo);
    procedure AdjustTotalCount(Node: PVirtualNode; Value: Integer; relative: Boolean = False);
    procedure AdjustTotalHeight(Node: PVirtualNode; Value: Integer; relative: Boolean = False);
    function CalculateCacheEntryCount: Integer;
    procedure CalculateVerticalAlignments(ShowImages, ShowStateImages: Boolean; Node: PVirtualNode; var VAlign,
      VButtonAlign: Integer);
    function ChangeCheckState(Node: PVirtualNode; Value: TCheckState): Boolean;
    function CollectSelectedNodesLTR(MainColumn, NodeLeft, NodeRight: Integer; Alignment: TAlignment; OldRect,
      NewRect: TRect): Boolean;
    function CollectSelectedNodesRTL(MainColumn, NodeLeft, NodeRight: Integer; Alignment: TAlignment; OldRect,
      NewRect: TRect): Boolean;
    procedure ClearNodeBackground(Canvas: TCanvas; Node: PVirtualNode; UseBackground, Floating: Boolean; R: TRect);
    function CompareNodePositions(Node1, Node2: PVirtualNode): Integer;
    function DetermineNextCheckState(CheckType: TCheckType; CheckState: TCheckState): TCheckState;
    procedure DrawLineImage(const PaintInfo: TVTPaintInfo; X, Y, H, VAlign: Integer; Style: TVTLineType; Reverse: Boolean);
    function FindInPositionCache(Node: PVirtualNode; var CurrentPos: Cardinal): PVirtualNode; overload;
    function FindInPositionCache(Position: Cardinal; var CurrentPos: Cardinal): PVirtualNode; overload;
    procedure FontChanged(AFont: TObject);
    function GetCheckState(Node: PVirtualNode): TCheckState;
    function GetCheckType(Node: PVirtualNode): TCheckType;
    function GetChildCount(Node: PVirtualNode): Cardinal;
    function GetChildrenInitialized(Node: PVirtualNode): Boolean;
    function GetDisabled(Node: PVirtualNode): Boolean;
    function GetDragManager: IVTDragManager;
    function GetExpanded(Node: PVirtualNode): Boolean;
    function GetFullyVisible(Node: PVirtualNode): Boolean;
    function GetHasChildren(Node: PVirtualNode): Boolean;
    function GetNodeHeight(Node: PVirtualNode): Cardinal;
    function GetOffsetXY: TPoint;
    function GetRootNodeCount: Cardinal;
    function GetSelected(Node: PVirtualNode): Boolean;
    function GetTopNode: PVirtualNode;
    function GetTotalCount: Cardinal;
    function GetVerticalAlignment(Node: PVirtualNode): Byte;
    function GetVisible(Node: PVirtualNode): Boolean;
    function GetVisiblePath(Node: PVirtualNode): Boolean;
    procedure HandleClickSelection(LastFocused, NewNode: PVirtualNode; Shift: TShiftState);
    function HandleDrawSelection(X, Y: Integer): Boolean;
    function HasVisibleNextSibling(Node: PVirtualNode): Boolean;
    procedure ImageListChange(Sender: TObject);
    procedure InitializeFirstColumnValues(var PaintInfo: TVTPaintInfo);
    function InitializeLineImageAndSelectLevel(Node: PVirtualNode; var LineImage: TLineImage): Integer;
    procedure InitRootNode(OldSize: Cardinal = 0);
    procedure InternalConnectNode(Node, Destination: PVirtualNode; Target: TBaseVirtualTree; Mode: TVTNodeAttachMode);
    procedure InternalDisconnectNode(Node: PVirtualNode; KeepFocus: Boolean);
    procedure InterruptValidation;
    function IsFirstVisibleChild(Parent, Node: PVirtualNode): Boolean;
    function IsLastVisibleChild(Parent, Node: PVirtualNode): Boolean;
    procedure LimitPaintingToArea(Canvas: TCanvas; ClipRect: TRect; VisibleRegion: HRGN = 0);
    function MakeNewNode: PVirtualNode;
    procedure OriginalWMNCPaint(DC: HDC);
    function PackArray(TheArray: TNodeArray; Count: Integer): Integer;
    procedure PaintCheckImage(const PaintInfo: TVTPaintInfo);
    procedure PaintImage(const PaintInfo: TVTPaintInfo; ImageInfoIndex: TVTImageInfoIndex; Images: TImageList;
      DoOverlay: Boolean);
    procedure PaintNodeButton(Canvas: TCanvas; Node: PVirtualNode; const R: TRect; ButtonX, ButtonY: Integer;
      BidiMode: TBiDiMode);
    procedure PaintTreeLines(const PaintInfo: TVTPaintInfo; VAlignment, IndentSize: Integer; LineImage: TLineImage);
    procedure PrepareBitmaps(NeedButtons, NeedLines: Boolean);
    procedure PrepareCell(var PaintInfo: TVTPaintInfo);
    procedure ReadOldOptions(Reader: TReader);
    procedure RedirectFontChangeEvent(Canvas: TCanvas);
    procedure RestoreFontChangeEvent(Canvas: TCanvas);
    procedure SetAlignment(const Value: TAlignment);
    procedure SetAnimationDuration(const Value: Cardinal);
    procedure SetBackground(const Value: TPicture);
    procedure SetBackgroundOffset(const Index, Value: Integer);
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure SetButtonFillMode(const Value: TVTButtonFillMode);
    procedure SetButtonStyle(const Value: TVTButtonStyle);
    procedure SetCheckImageKind(Value: TCheckImageKind);
    procedure SetCheckState(Node: PVirtualNode; Value: TCheckState);
    procedure SetCheckType(Node: PVirtualNode; Value: TCheckType);
    procedure SetChildCount(Node: PVirtualNode; NewChildCount: Cardinal);
    procedure SetClipboardFormats(const Value: TClipboardFormats);
    procedure SetColors(const Value: TVTColors);
    procedure SetCustomCheckImages(const Value: TImageList);
    procedure SetDisabled(Node: PVirtualNode; Value: Boolean);
    procedure SetExpanded(Node: PVirtualNode; Value: Boolean);
    procedure SetFocusedColumn(Value: Integer);
    procedure SetFocusedNode(Value: PVirtualNode);
    procedure SetFullyVisible(Node: PVirtualNode; Value: Boolean);
    procedure SetHasChildren(Node: PVirtualNode; Value: Boolean);
    procedure SetHeader(const Value: TVTHeader);
    procedure SetImages(const Value: TImageList);
    procedure SetIndent(Value: Cardinal);
    procedure SetItemHeight(Value: Cardinal);
    procedure SetLineMode(const Value: TVTLineMode);
    procedure SetLineStyle(const Value: TVTLineStyle);
    procedure SetMargin(Value: Integer);
    procedure SetNodeAlignment(const Value: TVTNodeAlignment);
    procedure SetNodeDataSize(Value: Integer);
    procedure SetNodeHeight(Node: PVirtualNode; Value: Cardinal);
    procedure SetOffsetX(const Value: Integer);
    procedure SetOffsetXY(const Value: TPoint);
    procedure SetOffsetY(const Value: Integer);
    procedure SetOptions(const Value: TCustomVirtualTreeOptions);
    procedure SetRootNodeCount(Value: Cardinal);
    procedure SetScrollBarOptions(Value: TScrollBarOptions);
    procedure SetSearchOption(const Value: TVTIncrementalSearch);
    procedure SetSelected(Node: PVirtualNode; Value: Boolean);
    procedure SetSelectionCurveRadius(const Value: Cardinal);
    procedure SetStateImages(const Value: TImageList);
    procedure SetTextMargin(Value: Integer);
    procedure SetTopNode(Node: PVirtualNode);
    procedure SetUpdateState(Updating: Boolean);
    procedure SetVerticalAlignment(Node: PVirtualNode; Value: Byte);
    procedure SetVisible(Node: PVirtualNode; Value: Boolean);
    procedure SetVisiblePath(Node: PVirtualNode; Value: Boolean);
    procedure StopTimer(ID: Integer);
    procedure TileBackground(Source: TBitmap; Target: TCanvas; Offset: TPoint; R: TRect);
    function ToggleCallback(Step, StepSize: Integer; Data: Pointer): Boolean;

    procedure CMColorChange(var Message: TMessage); message CM_COLORCHANGED;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
    procedure CMDrag(var Message: TCMDrag); message CM_DRAG;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMHintShow(var Message: TCMHintShow); message CM_HINTSHOW;
    procedure CMHintShowPause(var Message: TCMHintShowPause); message CM_HINTSHOWPAUSE;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMMouseWheel(var Message: TCMMouseWheel); message CM_MOUSEWHEEL;
    procedure CMSysColorChange(var Message: TMessage); message CM_SYSCOLORCHANGE;
    procedure WMChar(var Message: TWMChar); message WM_CHAR;
    procedure WMContextMenu(var Message: TWMContextMenu); message WM_CONTEXTMENU;
    procedure WMCopy(var Message: TWMCopy); message WM_COPY;
    procedure WMCut(var Message: TWMCut); message WM_CUT;
    procedure WMEnable(var Message: TWMEnable); message WM_ENABLE;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMHScroll(var Message: TWMVScroll); message WM_HSCROLL;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure WMKeyUp(var Message: TWMKeyUp); message WM_KEYUP;
    procedure WMKillFocus(var Msg: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMMButtonDblClk(var Message: TWMMButtonDblClk); message WM_MBUTTONDBLCLK;
    procedure WMMButtonDown(var Message: TWMMButtonDown); message WM_MBUTTONDOWN;
    procedure WMMButtonUp(var Message: TWMMButtonUp); message WM_MBUTTONUP;
    procedure WMNCCalcSize(var Message: TWMNCCalcSize); message WM_NCCALCSIZE;
    procedure WMNCDestroy(var Message: TWMNCDestroy); message WM_NCDESTROY;
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMNCPaint(var Message: TRealWMNCPaint); message WM_NCPAINT;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMPaste(var Message: TWMPaste); message WM_PASTE;
    procedure WMPrint(var Message: TWMPrint); message WM_PRINT;
    procedure WMPrintClient(var Message: TWMPrintClient); message WM_PRINTCLIENT;
    procedure WMRButtonDblClk(var Message: TWMRButtonDblClk); message WM_RBUTTONDBLCLK;
    procedure WMRButtonDown(var Message: TWMRButtonDown); message WM_RBUTTONDOWN;
    procedure WMRButtonUp(var Message: TWMRButtonUp); message WM_RBUTTONUP;
    procedure WMReleaseEditLink(var Message: TMessage); message WM_RELEASEEDITLINK;
    procedure WMSetCursor(var Message: TWMSetCursor); message WM_SETCURSOR;
    procedure WMSetFocus(var Msg: TWMSetFocus); message WM_SETFOCUS;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMThemeChanged(var Message: TMessage); message WM_THEMECHANGED;
    procedure WMTimer(var Message: TWMTimer); message WM_TIMER;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
  protected
    procedure AddToSelection(Node: PVirtualNode); overload;
    procedure AddToSelection(const NewItems: TNodeArray; NewLength: Integer; ForceInsert: Boolean = False); overload;
    procedure AdjustPaintCellRect(var PaintInfo: TVTPaintInfo; var NextNonEmpty: TColumnIndex); virtual;
    procedure AdjustPanningCursor(X, Y: Integer);
    procedure AdviseChangeEvent(StructureChange: Boolean; Node: PVirtualNode; Reason: TChangeReason);
    function AllocateInternalDataArea(Size: Cardinal): Cardinal;
    procedure Animate(Steps, Duration: Integer; Callback: TVTAnimationCallback; Data: Pointer);
    function CalculateSelectionRect(X, Y: Integer): Boolean;
    function CanAutoScroll: Boolean; virtual;
    function CanEdit(Node: PVirtualNode; Column: Integer): Boolean; virtual;
    function CanSelect(Node: PVirtualNode): Boolean; virtual;
    function CanShowDragImage: Boolean; virtual;
    procedure Change(Node: PVirtualNode);
    function CheckParentCheckState(Node: PVirtualNode; NewCheckState: TCheckState): Boolean;
    procedure ClearTempCache;
    function ColumnIsEmpty(Node: PVirtualNode; Column: Integer): Boolean; virtual;
    function CountLevelDifference(Node1, Node2: PVirtualNode): Integer;
    function CountVisibleChildren(Node: PVirtualNode): Cardinal;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure DefineProperties(Filer: TFiler); override;
    procedure DetermineHitPositionLTR(var HitInfo: THitInfo; Offset, Right: Integer; Alignment: TAlignment);
    procedure DetermineHitPositionRTL(var HitInfo: THitInfo; Offset, Right: Integer; Alignment: TAlignment);
    function DetermineScrollDirections(X, Y: Integer): TScrollDirections;
    procedure DoAfterCellPaint(Canvas: TCanvas; Node: PVirtualNode; Column: Integer; CellRect: TRect); virtual;
    procedure DoAfterItemErase(Canvas: TCanvas; Node: PVirtualNode; ItemRect: TRect); virtual;
    procedure DoAfterItemPaint(Canvas: TCanvas; Node: PVirtualNode; ItemRect: TRect); virtual;
    procedure DoAfterPaint(Canvas: TCanvas); virtual;
    procedure DoAutoScroll(X, Y: Integer); virtual;
    function DoBeforeDrag(Node: PVirtualNode; Column: Integer): Boolean; virtual;
    procedure DoBeforeCellPaint(Canvas: TCanvas; Node: PVirtualNode; Column: Integer; CellRect: TRect); virtual;
    procedure DoBeforeItemErase(Canvas: TCanvas; Node: PVirtualNode; ItemRect: TRect; var Color: TColor;
      var EraseAction: TItemEraseAction); virtual;
    function DoBeforeItemPaint(Canvas: TCanvas; Node: PVirtualNode; ItemRect: TRect): Boolean; virtual;
    procedure DoBeforePaint(Canvas: TCanvas); virtual;
    function DoCancelEdit: Boolean; virtual;
    procedure DoCanEdit(Node: PVirtualNode; Column: Integer; var Allowed: Boolean); virtual;
    procedure DoChange(Node: PVirtualNode); virtual;
    procedure DoCheckClick(Node: PVirtualNode; NewCheckState: TCheckState); virtual;
    procedure DoChecked(Node: PVirtualNode); virtual;
    function DoChecking(Node: PVirtualNode; var NewCheckState: TCheckState): Boolean; virtual;
    procedure DoCollapsed(Node: PVirtualNode); virtual;
    function DoCollapsing(Node: PVirtualNode): Boolean; virtual;
    procedure DoColumnClick(Column: Integer; Shift: TShiftState); virtual;
    procedure DoColumnDblClick(Column: Integer; Shift: TShiftState); virtual;
    procedure DoColumnResize(Column: Integer); virtual;
    function DoCompare(Node1, Node2: PVirtualNode; Column: Integer): Integer; virtual;
    function DoCreateDataObject: IDataObject; virtual;
    function DoCreateDragManager: IVTDragManager; virtual;
    function DoCreateEditor(Node: PVirtualNode; Column: Integer): IVTEditLink; virtual;
    procedure DoDragging(P: TPoint);
    procedure DoDragExpand;
    function DoDragOver(Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer): Boolean; virtual;
    procedure DoDragDrop(Source: TObject; DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState; Pt: TPoint;
      var Effect: Integer; Mode: TDropMode); virtual;
    procedure DoHeaderDraw(Canvas: TCanvas; Column: TVirtualTreeColumn; R: TRect; Hover, Pressed: Boolean;
      DropMark: TVTDropMarkMode); virtual;
    procedure DoEdit; virtual;
    procedure DoEndDrag(Target: TObject; X, Y: Integer); override;
    function DoEndEdit: Boolean; virtual;
    procedure DoExpanded(Node: PVirtualNode); virtual;
    function DoExpanding(Node: PVirtualNode): Boolean; virtual;
    procedure DoFocusChange(Node: PVirtualNode; Column: Integer); virtual;
    function DoFocusChanging(OldNode, NewNode: PVirtualNode; OldColumn, NewColumn: Integer): Boolean; virtual;
    procedure DoFocusNode(Node: PVirtualNode; Ask: Boolean); virtual;
    procedure DoFreeNode(Node: PVirtualNode); virtual;
    function DoGetAnimationType: THintAnimationType; virtual;
    procedure DoGetCursor(var Cursor: TCursor); virtual;
    procedure DoGetHeaderCursor(var Cursor: HCURSOR); virtual;
    procedure DoGetImageIndex(Node: PVirtualNode; Kind: TVTImageKind; Column: Integer;
      var Ghosted: Boolean; var Index: Integer); virtual;
    procedure DoGetLineStyle(var Bits: Pointer); virtual;
    function DoGetNodeHint(Node: PVirtualNode; Column: Integer): WideString; virtual;
    function DoGetNodeTooltip(Node: PVirtualNode; Column: Integer): WideString; virtual;
    function DoGetNodeWidth(Node: PVirtualNode; Column: Integer; Canvas: TCanvas = nil): Integer; virtual;
    function DoGetPopupMenu(Node: PVirtualNode; Column: Integer; Position: TPoint): TPopupMenu; virtual;
    procedure DoGetUserClipboardFormats(var Formats: TFormatEtcArray); virtual;
    procedure DoHeaderClick(Column: Integer; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure DoHeaderDblClick(Column: Integer; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure DoHeaderDragged(Column: TColumnIndex; OldPosition: TColumnPosition); virtual;
    function DoHeaderDragging(Column: TColumnIndex): Boolean; virtual;
    procedure DoHeaderMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure DoHeaderMouseMove(Shift: TShiftState; X, Y: Integer); virtual;
    procedure DoHeaderMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure DoHotChange(Old, New: PVirtualNode); virtual;
    function DoIncrementalSearch(Node: PVirtualNode; const Text: WideString): Integer; virtual;
    procedure DoInitChildren(Node: PVirtualNode; var ChildCount: Cardinal); virtual;
    procedure DoInitNode(Parent, Node: PVirtualNode; var InitStates: TVirtualNodeInitStates); virtual;
    function DoKeyAction(var CharCode: Word; var Shift: TShiftState): Boolean; virtual;
    procedure DoLoadUserData(Node: PVirtualNode; Stream: TStream); virtual;
    procedure DoNodeCopied(Node: PVirtualNode); virtual;
    function DoNodeCopying(Node, NewParent: PVirtualNode): Boolean; virtual;
    procedure DoNodeMoved(Node: PVirtualNode); virtual;
    function DoNodeMoving(Node, NewParent: PVirtualNode): Boolean; virtual;
    function DoPaintBackground(Canvas: TCanvas; R: TRect): Boolean; virtual;
    procedure DoPaintDropMark(Canvas: TCanvas; Node: PVirtualNode; R: TRect); virtual;
    procedure DoPaintNode(var PaintInfo: TVTPaintInfo); virtual;
    procedure DoPopupMenu(Node: PVirtualNode; Column: Integer; Position: TPoint); virtual;
    function DoRenderOLEData(const FormatEtcIn: TFormatEtc; out Medium: TStgMedium;
      ForClipboard: Boolean): HRESULT; virtual;
    procedure DoReset(Node: PVirtualNode); virtual;
    procedure DoSaveUserData(Node: PVirtualNode; Stream: TStream); virtual;
    procedure DoScroll(DeltaX, DeltaY: Integer); virtual;
    function DoSetOffsetXY(Value: TPoint; Options: TScrollUpdateOptions; ClipRect: PRect = nil): Boolean; virtual;
    procedure DoStructureChange(Node: PVirtualNode; Reason: TChangeReason); virtual;
    procedure DoTimerScroll;
    procedure DoUpdating(State: TVTUpdateState); virtual;
    procedure DoValidateCache;
    procedure DragCanceled; override;
    function DragDrop(const DataObject: IDataObject; KeyState: Integer; Pt: TPoint;
      var Effect: Integer): HResult; reintroduce; virtual;
    function DragEnter(KeyState: Integer; Pt: TPoint; var Effect: Integer): HResult; virtual;
    procedure DragFinished;
    procedure DragLeave; virtual;
    function DragOver(Source: TObject; KeyState: Integer; DragState: TDragState; Pt: TPoint;
      var Effect: Integer): HResult; reintroduce; virtual;
    procedure DrawDottedHLine(const PaintInfo: TVTPaintInfo; Left, Right, Top: Integer);
    procedure DrawDottedVLine(const PaintInfo: TVTPaintInfo; Top, Bottom, Left: Integer);
    function FindNodeInSelection(P: PVirtualNode; var Index: Integer; LowBound, HighBound: Integer): Boolean;
    procedure FinishChunkHeader(Stream: TStream; StartPos, EndPos: Integer);
    function GetCheckImage(Node: PVirtualNode): Integer; virtual;
    function GetColumnClass: TVirtualTreeColumnClass; virtual;
    function GetHeaderClass: TVTHeaderClass; virtual;
    function GetImageIndex(Node: PVirtualNode; Kind: TVTImageKind; Column: Integer; var Ghosted: Boolean): Integer;
    function GetMaxRightExtend: Cardinal;
    procedure GetNativeClipboardFormats(var Formats: TFormatEtcArray); virtual;
    function GetOptionsClass: TTreeOptionsClass; virtual;
    procedure GetTextInfo(Node: PVirtualNode; Column: Integer; const AFont: TFont; var R: TRect;
      var Text: WideString); virtual;
    function GetTreeFromDataObject(const DataObject: IDataObject): TBaseVirtualTree;
    procedure HandleHotTrack(X, Y: Integer);
    procedure HandleIncrementalSearch(CharCode: Word);
    procedure HandleMouseDblClick(var Message: TWMMouse; const HitInfo: THitInfo);
    procedure HandleMouseDown(var Message: TWMMouse; const HitInfo: THitInfo);
    procedure HandleMouseUp(var Message: TWMMouse; const HitInfo: THitInfo);
    function HasPopupMenu(Node: PVirtualNode; Column: Integer; Pos: TPoint): Boolean; virtual;
    procedure InitChildren(Node: PVirtualNode);
    procedure InitNode(Node: PVirtualNode);
    procedure InternalAddFromStream(Stream: TStream; Version: Integer; Node: PVirtualNode);
    function InternalAddToSelection(Node: PVirtualNode; ForceInsert: Boolean): Boolean; overload;
    function InternalAddToSelection(const NewItems: TNodeArray; NewLength: Integer;
      ForceInsert: Boolean): Boolean; overload;
    procedure InternalCacheNode(Node: PVirtualNode);
    procedure InternalClearSelection;
    function InternalData(Node: PVirtualNode): Pointer;
    procedure InternalRemoveFromSelection(Node: PVirtualNode);
    procedure InvalidateCache;
    procedure Loaded; override;
    procedure MainColumnChanged; virtual;
    procedure MarkCutCopyNodes;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Paint; override;
    procedure PaintSelectionRectangle(Target: TCanvas; WindowOrgX: Integer; const SelectionRect: TRect;
      TargetRect: TRect);
    procedure PaintTree(TargetCanvas: TCanvas; Window: TRect; Target: TPoint; PaintOptions: TVTInternalPaintOptions);
    procedure PanningWindowProc(var Message: TMessage);
    function ReadChunk(Stream: TStream; Version: Integer; Node: PVirtualNode; ChunkType,
      ChunkSize: Integer): Boolean; virtual;
    procedure ReadNode(Stream: TStream; Version: Integer; Node: PVirtualNode); virtual;
    procedure RemoveFromSelection(Node: PVirtualNode);
    function RenderOLEData(const FormatEtcIn: TFormatEtc; out Medium: TStgMedium; ForClipboard: Boolean): HResult; virtual;
    procedure ResetRangeAnchor;
    procedure SelectNodes(StartNode, EndNode: PVirtualNode; AddOnly: Boolean);
    procedure SetBiDiMode(Value: TBiDiMode); override;
    procedure SkipNode(Stream: TStream); virtual;
    procedure StartWheelPanning(Position: TPoint);
    procedure StopWheelPanning;
    procedure StructureChange(Node: PVirtualNode; Reason: TChangeReason);
    function SuggestDropEffect(Source: TObject; Shift: TShiftState; Pt: TPoint; AllowedEffects: Integer): Integer; virtual;
    procedure ToggleSelection(StartNode, EndNode: PVirtualNode);
    procedure UnselectNodes(StartNode, EndNode: PVirtualNode);
    procedure UpdateDesigner;
    procedure UpdateEditBounds;
    procedure UpdateHeaderRect;
    procedure UpdateWindowAndDragImage(const Tree: TBaseVirtualTree; TreeRect: TRect; UpdateNCArea,
      ReshowDragImage: Boolean);
    procedure ValidateCache;
    procedure ValidateNodeDataSize(var Size: Integer); virtual;
    procedure WndProc(var Message: TMessage); override;
    procedure WriteChunks(Stream: TStream; Node: PVirtualNode); virtual;
    procedure WriteNode(Stream: TStream; Node: PVirtualNode);

    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property AnimationDuration: Cardinal read FAnimationDuration write SetAnimationDuration default 200;
    property AutoExpandDelay: Cardinal read FAutoExpandDelay write FAutoExpandDelay default 1000;
    property AutoScrollDelay: Cardinal read FAutoScrollDelay write FAutoScrollDelay default 1000;
    property AutoScrollInterval: TAutoScrollInterval read FAutoScrollInterval write FAutoScrollInterval default 1;
    property Background: TPicture read FBackground write SetBackground;
    property BackgroundOffsetX: Integer index 0 read FBackgroundOffsetX write SetBackgroundOffset default 0;
    property BackgroundOffsetY: Integer index 1 read FBackgroundOffsetY write SetBackgroundOffset default 0;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle;
    property ButtonFillMode: TVTButtonFillMode read FButtonFillMode write SetButtonFillMode default fmTreeColor;
    property ButtonStyle: TVTButtonStyle read FButtonStyle write SetButtonStyle default bsRectangle;
    property ChangeDelay: Cardinal read FChangeDelay write FChangeDelay default 0;
    property CheckImageKind: TCheckImageKind read FCheckImageKind write SetCheckImageKind default ckLightCheck;
    property ClipboardFormats: TClipboardFormats read FClipboardFormats write SetClipboardFormats;
    property Colors: TVTColors read FColors write SetColors;
    property CustomCheckImages: TImageList read FCustomCheckImages write SetCustomCheckImages;
    property DefaultNodeHeight: Cardinal read FDefaultNodeHeight write SetItemHeight default 18;
    property DefaultPasteMode: TVTNodeAttachMode read FDefaultPasteMode write FDefaultPasteMode default amAddChildLast;
    property DragHeight: Integer read FDragHeight write FDragHeight default 350;
    property DragImageKind: TVTDragImageKind read FDragImageKind write FDragImageKind default diComplete;
    property DragOperations: TDragOperations read FDragOperations write FDragOperations default [doCopy, doMove];
    property DragSelection: TNodeArray read FDragSelection;
    property DragType: TVTDragType read FDragType write FDragType default dtOLE;
    property DragWidth: Integer read FDragWidth write FDragWidth default 200;
    property DrawSelectionMode: TVTDrawSelectionMode read FDrawSelectionMode write FDrawSelectionMode
      default smDottedRectangle;
    property EditDelay: Cardinal read FEditDelay write FEditDelay default 1000;
    property Header: TVTHeader read FHeader write SetHeader;
    property HintAnimation: THintAnimationType read FAnimationType write FAnimationType;
    property HintMode: TVTHintMode read FHintMode write FHintMode;
    property HotCursor: TCursor read FHotCursor write FHotCursor default crDefault;
    property Images: TImageList read FImages write SetImages;
    property IncrementalSearch: TVTIncrementalSearch read FIncrementalSearch write SetSearchOption default isNone;
    property IncrementalSearchDirection: TVTSearchDirection read FSearchDirection write FSearchDirection;
    property IncrementalSearchStart: TVTSearchStart read FSearchStart write FSearchStart default ssFocusedNode;
    property IncrementalSearchTimeout: Cardinal read FSearchTimeout write FSearchTimeout default 1000;
    property Indent: Cardinal read FIndent write SetIndent default 18;
    property LastDropMode: TDropMode read FLastDropMode write FlastDropMode;
    property LineMode: TVTLineMode read FLineMode write SetLineMode default lmNormal;
    property LineStyle: TVTLineStyle read FLineStyle write SetLineStyle default lsDotted;
    property Margin: Integer read FMargin write SetMargin default 4;
    property NodeAlignment: TVTNodeAlignment read FNodeAlignment write SetNodeAlignment default naProportional;
    property NodeDataSize: Integer read FNodeDataSize write SetNodeDataSize default -1;
    property RootNodeCount: Cardinal read GetRootNodeCount write SetRootNodeCount default 0;
    property ScrollBarOptions: TScrollBarOptions read FScrollBarOptions write SetScrollBarOptions;
    property SelectionCurveRadius: Cardinal read FSelectionCurveRadius write SetSelectionCurveRadius default 0;
    property StateImages: TImageList read FStateImages write SetStateImages;
    property TextMargin: Integer read FTextMargin write SetTextMargin default 4;
    property TotalInternalDataSize: Cardinal read FTotalInternalDataSize;
    property TreeOptions: TCustomVirtualTreeOptions read FOptions write SetOptions;
    property WantTabs: Boolean read FWantTabs write FWantTabs default False;

    property OnAfterCellPaint: TVTAfterCellPaintEvent read FOnAfterCellPaint write FOnAfterCellPaint;
    property OnAfterItemErase: TVTAfterItemEraseEvent read FOnAfterItemErase write FOnAfterItemErase;
    property OnAfterItemPaint: TVTAfterItemPaintEvent read FOnAfterItemPaint write FOnAfterItemPaint;
    property OnAfterPaint: TVTPaintEvent read FOnAfterPaint write FOnAfterPaint;
    property OnBeforeCellPaint: TVTBeforeCellPaintEvent read FOnBeforeCellPaint write FOnBeforeCellPaint;
    property OnBeforeItemErase: TVTBeforeItemEraseEvent read FOnBeforeItemErase write FOnBeforeItemErase;
    property OnBeforeItemPaint: TVTBeforeItemPaintEvent read FOnBeforeItemPaint write FOnBeforeItemPaint;
    property OnBeforePaint: TVTPaintEvent read FOnBeforePaint write FOnBeforePaint;
    property OnChange: TVTChangeEvent read FOnChange write FOnChange;
    property OnChecked: TVTChangeEvent read FOnChecked write FOnChecked;
    property OnChecking: TVTCheckChangingEvent read FOnChecking write FOnChecking;
    property OnCollapsed: TVTChangeEvent read FOnCollapsed write FOnCollapsed;
    property OnCollapsing: TVTChangingEvent read FOnCollapsing write FOnCollapsing;
    property OnColumnClick: TVTColumnClickEvent read FOnColumnClick write FOnColumnClick;
    property OnColumnDblClick: TVTColumnDblClickEvent read FOnColumnDblClick write FOnColumnDblClick;
    property OnColumnResize: TVTHeaderNotifyEvent read FOnColumnResize write FOnColumnResize;
    property OnCompareNodes: TVTCompareEvent read FOnCompareNodes write FOnCompareNodes;
    property OnCreateDataObject: TVTCreateDataObjectEvent read FOnCreateDataObject write FOnCreateDataObject;
    property OnCreateDragManager: TVTCreateDragManagerEvent read FOnCreateDragManager write FOnCreateDragManager;
    property OnCreateEditor: TVTCreateEditorEvent read FOnCreateEditor write FOnCreateEditor;
    property OnDragAllowed: TVTDragAllowedEvent read FOnDragAllowed write FOnDragAllowed;
    property OnDragOver: TVTDragOverEvent read FOnDragOver write FOnDragOver;
    property OnDragDrop: TVTDragDropEvent read FOnDragDrop write FOnDragDrop;
    property OnEditCancelled: TVTEditCancelEvent read FOnEditCancelled write FOnEditCancelled;
    property OnEditing: TVTEditChangingEvent read FOnEditing write FOnEditing;
    property OnEdited: TVTEditChangeEvent read FOnEdited write FOnEdited;
    property OnExpanded: TVTChangeEvent read FOnExpanded write FOnExpanded;
    property OnExpanding: TVTChangingEvent read FOnExpanding write FOnExpanding;
    property OnFocusChanged: TVTFocusChangeEvent read FOnFocusChanged write FOnFocusChanged;
    property OnFocusChanging: TVTFocusChangingEvent read FOnFocusChanging write FOnFocusChanging;
    property OnFreeNode: TVTFreeNodeEvent read FOnFreeNode write FOnFreeNode;
    property OnGetCursor: TVTGetCursorEvent read FOnGetCursor write FOnGetCursor;
    property OnGetHeaderCursor: TVTGetHeaderCursorEvent read FOnGetHeaderCursor write FOnGetHeaderCursor;
    property OnGetHelpContext: TVTHelpContextEvent read FOnGetHelpContext write FOnGetHelpContext;
    property OnGetImageIndex: TVTGetImageEvent read FOnGetImage write FOnGetImage;
    property OnGetLineStyle: TVTGetLineStyleEvent read FOnGetLineStyle write FOnGetLineStyle;
    property OnGetNodeDataSize: TVTGetNodeDataSizeEvent read FOnGetNodeDataSize write FOnGetNodeDataSize;
    property OnGetPopupMenu: TVTPopupEvent read FOnGetPopupMenu write FOnGetPopupMenu;
    property OnGetUserClipboardFormats: TVTGetUserClipboardFormatsEvent read FOnGetUserClipboardFormats
      write FOnGetUserClipboardFormats;
    property OnHeaderClick: TVTHeaderClickEvent read FOnHeaderClick write FOnHeaderClick;
    property OnHeaderDblClick: TVTHeaderClickEvent read FOnHeaderDblClick write FOnHeaderDblClick;
    property OnHeaderDragged: TVTHeaderDraggedEvent read FOnHeaderDragged write FOnHeaderDragged;
    property OnHeaderDragging: TVTHeaderDraggingEvent read FOnHeaderDragging write FOnHeaderDragging;
    property OnHeaderDraw: TVTHeaderPaintEvent read FOnHeaderDraw write FOnHeaderDraw;
    property OnHeaderMouseDown: TVTHeaderMouseEvent read FOnHeaderMouseDown write FOnHeaderMouseDown;
    property OnHeaderMouseMove: TVTHeaderMouseMoveEvent read FOnHeaderMouseMove write FOnHeaderMouseMove;
    property OnHeaderMouseUp: TVTHeaderMouseEvent read FOnHeaderMouseUp write FOnHeaderMouseUp;
    property OnHotChange: TVTHotNodeChangeEvent read FOnHotChange write FOnHotChange;
    property OnIncrementalSearch: TVTIncrementalSearchEvent read FOnIncrementalSearch write FOnIncrementalSearch;
    property OnInitChildren: TVTInitChildrenEvent read FOnInitChildren write FOnInitChildren;
    property OnInitNode: TVTInitNodeEvent read FOnInitNode write FOnInitNode;
    property OnKeyAction: TVTKeyActionEvent read FOnKeyAction write FOnKeyAction;
    property OnLoadNode: TVTSaveNodeEvent read FOnLoadNode write FOnLoadNode;
    property OnNodeCopied: TVTNodeCopiedEvent read FOnNodeCopied write FOnNodeCopied;
    property OnNodeCopying: TVTNodeCopyingEvent read FOnNodeCopying write FOnNodeCopying;
    property OnNodeMoved: TVTNodeMovedEvent read FOnNodeMoved write FOnNodeMoved;
    property OnNodeMoving: TVTNodeMovingEvent read FOnNodeMoving write FOnNodeMoving;
    property OnPaintBackground: TVTBackgroundPaintEvent read FOnPaintBackground write FOnPaintBackground;
    property OnRenderOLEData: TVTRenderOLEDataEvent read FOnRenderOLEData write FOnRenderOLEData;
    property OnResetNode: TVTChangeEvent read FOnResetNode write FOnResetNode;
    property OnSaveNode: TVTSaveNodeEvent read FOnSaveNode write FOnSaveNode;
    property OnScroll: TVTScrollEvent read FOnScroll write FOnScroll;
    property OnStructureChange: TVTStructureChangeEvent read FOnStructureChange write FOnStructureChange;
    property OnUpdating: TVTUpdatingEvent read FOnUpdating write FOnUpdating;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function AbsoluteIndex(Node: PVirtualNode): Cardinal;
    function AddChild(Parent: PVirtualNode; UserData: Pointer = nil): PVirtualNode;
    procedure AddFromStream(Stream: TStream; TargetNode: PVirtualNode);
    procedure AfterConstruction; override;
    procedure Assign(Source: TPersistent); override;
    procedure BeginDrag(Immediate: Boolean; Threshold: Integer = -1);
    procedure BeginSynch;
    procedure BeginUpdate;
    procedure CancelCutOrCopy; 
    function CancelEditNode: Boolean;
    procedure Clear; virtual;
    procedure ClearSelection;
    function CopyTo(Source: PVirtualNode; Tree: TBaseVirtualTree; Mode: TVTNodeAttachMode;
      ChildrenOnly: Boolean): PVirtualNode; overload;
    function CopyTo(Source, Target: PVirtualNode; Mode: TVTNodeAttachMode;
      ChildrenOnly: Boolean): PVirtualNode; overload;
    procedure CopyToClipBoard; virtual;
    procedure CutToClipBoard; virtual;
    procedure DeleteChildren(Node: PVirtualNode; ResetHasChildren: Boolean = False);
    procedure DeleteNode(Node: PVirtualNode);
    procedure DeleteSelectedNodes;
    function Dragging: Boolean;
    function EditNode(Node: PVirtualNode; Column: Integer): Boolean; virtual;
    function EndEditNode: Boolean;
    procedure EndSynch;
    procedure EndUpdate;
    function ExecuteAction(Action: TBasicAction): Boolean; override;
    procedure FinishCutOrCopy;
    procedure FlushClipboard;
    procedure FullCollapse(Node: PVirtualNode = nil);  virtual;
    procedure FullExpand(Node: PVirtualNode = nil); virtual;
    function GetControlsAlignment: TAlignment; override;
    function GetDisplayRect(Node: PVirtualNode; Column: Integer; TextOnly: Boolean; Unclipped: Boolean = False): TRect;
    function GetFirstChild(Node: PVirtualNode): PVirtualNode;
    function GetFirst: PVirtualNode;
    function GetFirstCutCopy: PVirtualNode;
    function GetFirstInitialized: PVirtualNode;
    function GetFirstNoInit: PVirtualNode;
    function GetFirstSelected: PVirtualNode;
    function GetFirstVisible: PVirtualNode;
    function GetFirstVisibleChild(Node: PVirtualNode): PVirtualNode;
    function GetFirstVisibleChildNoInit(Node: PVirtualNode): PVirtualNode;
    function GetFirstVisibleNoInit: PVirtualNode;
    procedure GetHitTestInfoAt(X, Y: Integer; Relative: Boolean; var HitInfo: THitInfo);
    function GetLast(Node: PVirtualNode = nil): PVirtualNode;
    function GetLastInitialized(Node: PVirtualNode = nil): PVirtualNode;
    function GetLastNoInit(Node: PVirtualNode = nil): PVirtualNode;
    function GetLastChild(Node: PVirtualNode): PVirtualNode;
    function GetLastChildNoInit(Node: PVirtualNode): PVirtualNode;
    function GetLastVisible(Node: PVirtualNode = nil): PVirtualNode;
    function GetLastVisibleChild(Node: PVirtualNode): PVirtualNode;
    function GetLastVisibleChildNoInit(Node: PVirtualNode): PVirtualNode;
    function GetLastVisibleNoInit(Node: PVirtualNode = nil): PVirtualNode;
    function GetMaxColumnWidth(Column: Integer): Integer;
    function GetNext(Node: PVirtualNode): PVirtualNode;
    function GetNextCutCopy(Node: PVirtualNode): PVirtualNode;
    function GetNextInitialized(Node: PVirtualNode): PVirtualNode;
    function GetNextNoInit(Node: PVirtualNode): PVirtualNode;
    function GetNextSelected(Node: PVirtualNode): PVirtualNode;
    function GetNextSibling(Node: PVirtualNode): PVirtualNode;
    function GetNextVisible(Node: PVirtualNode): PVirtualNode;
    function GetNextVisibleNoInit(Node: PVirtualNode): PVirtualNode;
    function GetNextVisibleSibling(Node: PVirtualNode): PVirtualNode;
    function GetNextVisibleSiblingNoInit(Node: PVirtualNode): PVirtualNode;
    function GetNodeAt(X, Y: Integer): PVirtualNode; overload;
    function GetNodeAt(X, Y: Integer; Relative: Boolean; var NodeTop: Integer): PVirtualNode; overload;
    function GetNodeData(Node: PVirtualNode): Pointer;
    function GetNodeLevel(Node: PVirtualNode): Cardinal;
    function GetPrevious(Node: PVirtualNode): PVirtualNode;
    function GetPreviousInitialized(Node: PVirtualNode): PVirtualNode;
    function GetPreviousNoInit(Node: PVirtualNode): PVirtualNode;
    function GetPreviousSibling(Node: PVirtualNode): PVirtualNode;
    function GetPreviousVisible(Node: PVirtualNode): PVirtualNode;
    function GetPreviousVisibleNoInit(Node: PVirtualNode): PVirtualNode;
    function GetPreviousVisibleSibling(Node: PVirtualNode): PVirtualNode;
    function GetPreviousVisibleSiblingNoInit(Node: PVirtualNode): PVirtualNode;
    function GetSortedCutCopySet(Resolve: Boolean): TNodeArray;
    function GetSortedSelection(Resolve: Boolean): TNodeArray;
    function GetTreeRect: TRect;
    function GetVisibleParent(Node: PVirtualNode): PVirtualNode;
    function HasAsParent(Node, PotentialParent: PVirtualNode): Boolean;
    function InsertNode(Node: PVirtualNode; Mode: TVTNodeAttachMode; UserData: Pointer = nil): PVirtualNode;
    procedure InvalidateChildren(Node: PVirtualNode; Recursive: Boolean);
    procedure InvalidateColumn(Column: Integer);
    function InvalidateNode(Node: PVirtualNode): TRect; virtual;
    procedure InvalidateToBottom(Node: PVirtualNode);
    procedure InvertSelection(VisibleOnly: Boolean);
    function IsEditing: Boolean;
    function IsMouseSelecting: Boolean;
    function IterateSubtree(Node: PVirtualNode; Callback: TVTGetNodeProc; Data: Pointer; Filter: TVirtualNodeStates = [];
      DoInit: Boolean = False; ChildNodesOnly: Boolean = False): PVirtualNode;
    procedure LoadFromFile(const FileName: TFileName); virtual;
    procedure LoadFromStream(Stream: TStream); virtual;
    procedure MoveTo(Source, Target: PVirtualNode; Mode: TVTNodeAttachMode; ChildrenOnly: Boolean); overload;
    procedure MoveTo(Node: PVirtualNode; Tree: TBaseVirtualTree; Mode: TVTNodeAttachMode;
      ChildrenOnly: Boolean); overload;
    function PasteFromClipboard: Boolean; virtual;
    procedure PrepareDragImage(HotSpot: TPoint; const DataObject: IDataObject);
    function ProcessDrop(DataObject: IDataObject; TargetNode: PVirtualNode; var Effect: Integer; Mode:
      TVTNodeAttachMode): Boolean;
    function ProcessOLEData(Source: TBaseVirtualTree; DataObject: IDataObject; TargetNode: PVirtualNode;
      Mode: TVTNodeAttachMode; Optimized: Boolean): Boolean;
    procedure RepaintNode(Node: PVirtualNode);
    procedure ReinitChildren(Node: PVirtualNode; Recursive: Boolean); virtual;
    procedure ReinitNode(Node: PVirtualNode; Recursive: Boolean); virtual;
    procedure ResetNode(Node: PVirtualNode); virtual;
    procedure SaveToFile(const FileName: TFileName);
    procedure SaveToStream(Stream: TStream; Node: PVirtualNode = nil); virtual;
    function ScrollIntoView(Node: PVirtualNode; Center: Boolean; Horizontally: Boolean = False): Boolean;
    procedure SelectAll(VisibleOnly: Boolean);
    procedure Sort(Node: PVirtualNode; Column: Integer; Direction: TSortDirection; DoInit: Boolean = True); virtual;
    procedure SortTree(Column: Integer; Direction: TSortDirection; DoInit: Boolean = True);
    procedure ToggleNode(Node: PVirtualNode);
    function UpdateAction(Action: TBasicAction): Boolean; override;
    procedure UpdateHorizontalScrollBar(DoRepaint: Boolean);
    procedure UpdateScrollBars(DoRepaint: Boolean);
    procedure UpdateVerticalScrollBar(DoRepaint: Boolean);
    function UseRightToLeftReading: Boolean;
    procedure ValidateChildren(Node: PVirtualNode; Recursive: Boolean);
    procedure ValidateNode(Node: PVirtualNode; Recursive: Boolean);

    property CheckState[Node: PVirtualNode]: TCheckState read GetCheckState write SetCheckState;
    property CheckType[Node: PVirtualNode]: TCheckType read GetCheckType write SetCheckType;
    property ChildCount[Node: PVirtualNode]: Cardinal read GetChildCount write SetChildCount;
    property ChildrenInitialized[Node: PVirtualNode]: Boolean read GetChildrenInitialized;
    property DragImage: TVTDragImage read FDragImage;
    property DragManager: IVTDragManager read GetDragManager;
    property DropTargetNode: PVirtualNode read FDropTargetNode;
    property EditLink: IVTEditLink read FEditLink;
    property Expanded[Node: PVirtualNode]: Boolean read GetExpanded write SetExpanded;
    property FocusedColumn: Integer read FFocusedColumn write SetFocusedColumn default InvalidColumn;
    property FocusedNode: PVirtualNode read FFocusedNode write SetFocusedNode;
    property Font;
    property FullyVisible[Node: PVirtualNode]: Boolean read GetFullyVisible write SetFullyVisible;
    property HasChildren[Node: PVirtualNode]: Boolean read GetHasChildren write SetHasChildren;
    property HotNode: PVirtualNode read FCurrentHotNode;
    property IsDisabled[Node: PVirtualNode]: Boolean read GetDisabled write SetDisabled;
    property IsVisible[Node: PVirtualNode]: Boolean read GetVisible write SetVisible;
    property NodeHeight[Node: PVirtualNode]: Cardinal read GetNodeHeight write SetNodeHeight;
    property OffsetX: Integer read FOffsetX write SetOffsetX;
    property OffsetXY: TPoint read GetOffsetXY write SetOffsetXY;
    property OffsetY: Integer read FOffsetY write SetOffsetY;
    property RootNode: PVirtualNode read FRoot;
    property Selected[Node: PVirtualNode]: Boolean read GetSelected write SetSelected;
    property TotalCount: Cardinal read GetTotalCount;
    property TreeStates: TVirtualTreeStates read FStates;
    property SelectedCount: Integer read FSelectionCount;
    property TopNode: PVirtualNode read GetTopNode write SetTopNode;
    property VerticalAlignment[Node: PVirtualNode]: Byte read GetVerticalAlignment write SetVerticalAlignment;
    property VisibleCount: Cardinal read FVisibleCount;
    property VisiblePath[Node: PVirtualNode]: Boolean read GetVisiblePath write SetVisiblePath;
  end;


  // --------- TCustomVirtualStringTree

  // Options regarding strings (useful only for the string tree and descentants):
  TVTStringOption = (
    toSaveCaptions,          // If set then the caption is automatically saved with the tree node, regardless of what is
                             // saved in the user data.
    toShowStaticText,        // Show static text in a caption which can be differently formatted than the caption
                             // but cannot be edited.
    toAutoAcceptEditChange   // Automatically accept changes during edit if the user finishes editing other then
                             // VK_RETURN or ESC. If not set then changes are cancelled.
  );
  TVTStringOptions = set of TVTStringOption;

const
  DefaultStringOptions = [toSaveCaptions, toAutoAcceptEditChange];

type
  TCustomStringTreeOptions = class(TCustomVirtualTreeOptions)
  private
    FStringOptions: TVTStringOptions;
    procedure SetStringOptions(const Value: TVTStringOptions);
  protected
    property StringOptions: TVTStringOptions read FStringOptions write SetStringOptions default DefaultStringOptions;
  public
    constructor Create(AOwner: TBaseVirtualTree); override;

    procedure AssignTo(Dest: TPersistent); override;
  end;

  TStringTreeOptions = class(TCustomStringTreeOptions)
  published
    property AnimationOptions;
    property AutoOptions;
    property MiscOptions;
    property PaintOptions;
    property SelectionOptions;
    property StringOptions;
  end;

  TCustomVirtualStringTree = class;

  // support classes
  TStringEditLink = class;

  TVTEdit = class(TCustomEdit)
  private
    FLink: TStringEditLink;
    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
    procedure WMChar(var Message: TWMChar); message WM_CHAR;
    procedure WMDestroy(var Message: TWMDestroy); message WM_DESTROY;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
  protected
    procedure AutoAdjustSize;
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(Link: TStringEditLink); reintroduce;
  end;

  TStringEditLink = class(TInterfacedObject, IVTEditLink)
  private
    FEdit: TVTEdit;                  // a normal custom edit control
    FTree: TCustomVirtualStringTree; // a back reference to the tree calling
    FNode: PVirtualNode;             // the node to be edited
    FColumn: TColumnIndex;           // the column of the node
    FAlignment: TAlignment;
    FTextBounds: TRect;              // smallest rectangle around the text
    FStopping: Boolean;              // set to True when the edit link requests stopping the edit action
  public
    constructor Create;
    destructor Destroy; override;

    function BeginEdit: Boolean; stdcall;
    function CancelEdit: Boolean; stdcall;
    function EndEdit: Boolean; stdcall;
    function GetBounds: TRect; stdcall;
    function PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean; stdcall;
    procedure ProcessMessage(var Message: TMessage); stdcall;
    procedure SetBounds(R: TRect); stdcall;
  end;
  
  // Describes the type of text to return in the text and draw info retrival events.
  TVSTTextType = (
    ttNormal,      // normal label of the node, this is also the text which can be edited
    ttStatic       // static (non-editable) text after the normal text
  );

  // Describes the source to use when converting a string tree into a string for clipboard etc.
  TVSTTextSourceType = (
    tstAll,             // All nodes are rendered. Initialization is done on the fly.
    tstInitialized,     // Only initialized nodes are rendered.
    tstSelected,        // Only selected nodes are rendered.
    tstCutCopySet,      // Only nodes currently marked as being in the cut/copy clipboard set are rendered.
    tstVisible          // Only visible nodes are rendered.
  );

  TVTPaintText = procedure(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: Integer;
    TextType: TVSTTextType) of object;
  TVSTGetTextEvent = procedure(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: Integer;
    TextType: TVSTTextType; var CellText: WideString) of object;
  // New text can only be set for variable caption.
  TVSTNewTextEvent = procedure(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: Integer;
    NewText: WideString) of object;
  TVSTShortenStringEvent = procedure(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; Column: Integer;
    const S: WideString; TextSpace: Integer; RightToLeft: Boolean; var Result: WideString; var Done: Boolean) of object;

  TCustomVirtualStringTree = class(TBaseVirtualTree)
  private
    FDefaultText: WideString;                    // text to show if there's no OnGetText event handler (e.g. at design time)
    FTextHeight: Integer;                        // true size of the font
    FEllipsisWidth: Integer;                     // width of '...' for the current font
    FInternalDataOffset: Cardinal;               // offset to the internal data of the string tree

    FOnPaintText: TVTPaintText;                  // triggered before either normal or fixed text is painted to allow
                                                 // even finer customization (kind of sub cell painting)
    FOnGetText,                                  // used to retrieve the string to be displayed for a specific node
    FOnGetHint: TVSTGetTextEvent;                // used to retrieve the hint to be displayed for a specific node
    FOnNewText: TVSTNewTextEvent;                // used to notify the application about an edited node caption
    FOnShortenString: TVSTShortenStringEvent;    // used to allow the application a customized string shortage

    procedure GetRenderStartValues(Source: TVSTTextSourceType; var Node: PVirtualNode;
      var NextNodeProc: TGetNextNodeProc);
    function GetOptions: TCustomStringTreeOptions;
    function GetText(Node: PVirtualNode; Column: Integer): WideString;
    procedure InitializeTextProperties(const Canvas: TCanvas; Node: PVirtualNode; Column: Integer);
    procedure PaintNormalText(var PaintInfo: TVTPaintInfo; TextOutFlags: Integer; Text: WideString);
    procedure PaintStaticText(const PaintInfo: TVTPaintInfo; TextOutFlags: Integer; const Text: WideString);
    procedure ReadText(Reader: TReader);
    procedure SetDefaultText(const Value: WideString);
    procedure SetOptions(const Value: TCustomStringTreeOptions);
    procedure SetText(Node: PVirtualNode; Column: Integer; const Value: WideString);
    procedure WriteText(Writer: TWriter);

    procedure WMSetFont(var Msg: TWMSetFont); message WM_SETFONT;
  protected
    procedure AdjustPaintCellRect(var PaintInfo: TVTPaintInfo; var NextNonEmpty: TColumnIndex); override;
    function CalculateTextWidth(Canvas: TCanvas; Node: PVirtualNode; Column: Integer; Text: WideString): Integer; virtual;
    function ColumnIsEmpty(Node: PVirtualNode; Column: Integer): Boolean; override;
    procedure DefineProperties(Filer: TFiler); override;
    function DoCreateEditor(Node: PVirtualNode; Column: Integer): IVTEditLink; override;
    function DoGetNodeHint(Node: PVirtualNode; Column: Integer): WideString; override;
    function DoGetNodeTooltip(Node: PVirtualNode; Column: Integer): WideString; override;
    function DoGetNodeWidth(Node: PVirtualNode; Column: Integer; Canvas: TCanvas = nil): Integer; override;
    procedure DoGetText(Node: PVirtualNode; Column: Integer; TextType: TVSTTextType;
      var Text: WideString); virtual;
    procedure DoNewText(Node: PVirtualNode; Column: Integer; Text: WideString); virtual;
    procedure DoPaintNode(var PaintInfo: TVTPaintInfo); override;
    procedure DoPaintText(Node: PVirtualNode; const Canvas: TCanvas; Column: Integer;
      TextType: TVSTTextType); virtual;
    function DoShortenString(Canvas: TCanvas; Node: PVirtualNode; Column: Integer; const S: WideString; Width: Integer;
      RightToLeft: Boolean; EllipsisWidth: Integer = 0): WideString; virtual;
    function GetOptionsClass: TTreeOptionsClass; override;
    procedure GetTextInfo(Node: PVirtualNode; Column: Integer; const AFont: TFont; var R: TRect;
      var Text: WideString); override;
    function InternalData(Node: PVirtualNode): Pointer;
    procedure MainColumnChanged; override;
    function ReadChunk(Stream: TStream; Version: Integer; Node: PVirtualNode; ChunkType,
      ChunkSize: Integer): Boolean; override;
    procedure ReadOldStringOptions(Reader: TReader);
    function RenderOLEData(const FormatEtcIn: TFormatEtc; out Medium: TStgMedium; ForClipboard: Boolean): HResult; override;
    procedure WriteChunks(Stream: TStream; Node: PVirtualNode); override;

    property DefaultText: WideString read FDefaultText write SetDefaultText stored False;
    property EllipsisWidth: Integer read FEllipsisWidth;
    property TreeOptions: TCustomStringTreeOptions read GetOptions write SetOptions;

    property OnGetHint: TVSTGettextEvent read FOnGetHint write FOnGetHint;
    property OnGetText: TVSTGetTextEvent read FOnGetText write FOnGetText;
    property OnNewText: TVSTNewTextEvent read FOnNewText write FOnNewText;
    property OnPaintText: TVTPaintText read FOnPaintText write FOnPaintText;
    property OnShortenString: TVSTShortenStringEvent read FOnShortenString write FOnShortenString;
  public
    constructor Create(AOwner: TComponent); override;

    function ContentToClipboard(Format: Word; Source: TVSTTextSourceType): HGLOBAL;
    function ContentToHTML(Source: TVSTTextSourceType; Caption: WideString = ''): string;
    function ContentToRTF(Source: TVSTTextSourceType): string;
    function ContentToText(Source: TVSTTextSourceType; Separator: Char): string;
    function ContentToUnicode(Source: TVSTTextSourceType; Separator: WideChar): WideString;
    function InvalidateNode(Node: PVirtualNode): TRect; override;
    function Path(Node: PVirtualNode; Column: Integer; TextType: TVSTTextType; Delimiter: WideChar): WideString;
    procedure ReinitNode(Node: PVirtualNode; Recursive: Boolean); override;

    property Text[Node: PVirtualNode; Column: Integer]: WideString read GetText write SetText;
  end;

  TVirtualStringTree = class(TCustomVirtualStringTree)
  private
    function GetOptions: TStringTreeOptions;
    procedure SetOptions(const Value: TStringTreeOptions);
  protected
    function GetOptionsClass: TTreeOptionsClass; override;
  public
    property Canvas;
  published
    property Action;
    property Align;
    property Alignment;
    property Anchors;
    property AnimationDuration;
    property AutoExpandDelay;
    property AutoScrollDelay;
    property AutoScrollInterval;
    property Background;
    property BackgroundOffsetX;
    property BackgroundOffsetY;
    property BiDiMode;
    property BevelEdges;
    property BevelInner;
    property BevelOuter;
    property BevelKind;
    property BevelWidth;
    property BorderStyle;
    property ButtonFillMode;
    property ButtonStyle;
    property BorderWidth;
    property ChangeDelay;
    property CheckImageKind;
    property ClipboardFormats;
    property Color;
    property Colors;
    property Constraints;
    property Ctl3D;
    property CustomCheckImages;
    property DefaultNodeHeight;
    property DefaultPasteMode;
    property DefaultText;
    property DragCursor;
    property DragHeight;
    property DragKind;
    property DragImageKind;
    property DragMode;
    property DragOperations;
    property DragType;
    property DragWidth;
    property DrawSelectionMode;
    property EditDelay;
    property Enabled;
    property Font;
    property Header;
    property HintAnimation;
    property HintMode;
    property HotCursor;
    property Images;
    property IncrementalSearch;
    property IncrementalSearchDirection;
    property IncrementalSearchStart;
    property IncrementalSearchTimeout;
    property Indent;
    property LineMode;
    property LineStyle;
    property Margin;
    property NodeAlignment;
    property NodeDataSize;
    property ParentBiDiMode;
    property ParentColor default False;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property RootNodeCount;
    property ScrollBarOptions;
    property SelectionCurveRadius;
    property ShowHint;
    property StateImages;
    property TabOrder;
    property TabStop default True;
    property TextMargin;
    property TreeOptions: TStringTreeOptions read GetOptions write SetOptions;
    property Visible;
    property WantTabs;

    property OnAfterCellPaint;
    property OnAfterItemErase;
    property OnAfterItemPaint;
    property OnAfterPaint;
    property OnBeforeCellPaint;
    property OnBeforeItemErase;
    property OnBeforeItemPaint;
    property OnBeforePaint;
    property OnChange;
    property OnChecked;
    property OnChecking;
    property OnClick;
    property OnCollapsed;
    property OnCollapsing;
    property OnColumnClick;
    property OnColumnDblClick;
    property OnColumnResize;
    property OnCompareNodes;
    {$ifdef COMPILER_5_UP}
      property OnContextPopup;
    {$endif COMPILER_5_UP}
    property OnCreateDataObject;
    property OnCreateDragManager;
    property OnCreateEditor;
    property OnDblClick;
    property OnDragAllowed;
    property OnDragOver;
    property OnDragDrop;
    property OnEditCancelled;
    property OnEdited;
    property OnEditing;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnExpanded;
    property OnExpanding;
    property OnFocusChanged;
    property OnFocusChanging;
    property OnFreeNode;
    property OnGetCursor;
    property OnGetHeaderCursor;
    property OnGetText;
    property OnPaintText;
    property OnGetHelpContext;
    property OnGetImageIndex;
    property OnGetHint;
    property OnGetLineStyle;
    property OnGetNodeDataSize;
    property OnGetPopupMenu;
    property OnGetUserClipboardFormats;
    property OnHeaderClick;
    property OnHeaderDblClick;
    property OnHeaderDragged;
    property OnHeaderDragging;
    property OnHeaderDraw;
    property OnHeaderMouseDown;
    property OnHeaderMouseMove;
    property OnHeaderMouseUp;
    property OnHotChange;
    property OnIncrementalSearch;
    property OnInitChildren;
    property OnInitNode;
    property OnKeyAction;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnLoadNode;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnNewText;
    property OnNodeCopied;
    property OnNodeCopying;
    property OnNodeMoved;
    property OnNodeMoving;
    property OnPaintBackground;
    property OnRenderOLEData;
    property OnResetNode;
    property OnResize;
    property OnSaveNode;
    property OnScroll;
    property OnShortenString;
    property OnStartDock;
    property OnStartDrag;
    property OnStructureChange;
    property OnUpdating;
  end;

  TVTDrawHintEvent = procedure(Sender: TBaseVirtualTree; HintCanvas: TCanvas; Node: PVirtualNode; R: TRect;
    Column: Integer) of object;
  TVTDrawNodeEvent = procedure(Sender: TBaseVirtualTree; const PaintInfo: TVTPaintInfo) of object;
  TVTGetNodeWidthEvent = procedure(Sender: TBaseVirtualTree; HintCanvas: TCanvas; Node: PVirtualNode; Column: Integer;
    var NodeWidth: Integer) of object;
  TVTGetHintSizeEvent = procedure(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: Integer; var R: TRect) of object;

  // Tree descentant to let an application draw its stuff itself.
  TCustomVirtualDrawTree = class(TBaseVirtualTree)
  private
    FOnDrawNode: TVTDrawNodeEvent;
    FOnGetNodeWidth: TVTGetNodeWidthEvent;
    FOnGetHintSize: TVTGetHintSizeEvent;
    FOnDrawHint: TVTDrawHintEvent;
  protected
    procedure DoDrawHint(Canvas: TCanvas; Node: PVirtualNode; R: TRect; Column: Integer);
    procedure DoGetHintSize(Node: PVirtualNode; Column: Integer; var R: TRect); virtual;
    function DoGetNodeWidth(Node: PVirtualNode; Column: Integer; Canvas: TCanvas = nil): Integer; override;
    procedure DoPaintNode(var PaintInfo: TVTPaintInfo); override;

    property OnDrawHint: TVTDrawHintEvent read FOnDrawHint write FOnDrawHint;
    property OnDrawNode: TVTDrawNodeEvent read FOnDrawNode write FOnDrawNode;
    property OnGetHintSize: TVTGetHintSizeEvent read FOnGetHintSize write FOnGetHintSize;
    property OnGetNodeWidth: TVTGetNodeWidthEvent read FOnGetNodeWidth write FOnGetNodeWidth;
  end;

  TVirtualDrawTree = class(TCustomVirtualDrawTree)
  private
    function GetOptions: TVirtualTreeOptions;
    procedure SetOptions(const Value: TVirtualTreeOptions);
  protected
    function GetOptionsClass: TTreeOptionsClass; override;
  public
    property Canvas;
  published
    property Action;
    property Align;
    property Alignment;
    property Anchors;
    property AnimationDuration;
    property AutoExpandDelay;
    property AutoScrollDelay;
    property AutoScrollInterval;
    property Background;
    property BackgroundOffsetX;
    property BackgroundOffsetY;
    property BiDiMode;
    property BevelEdges;
    property BevelInner;
    property BevelOuter;
    property BevelKind;
    property BevelWidth;
    property BorderStyle;
    property ButtonFillMode;
    property ButtonStyle;
    property BorderWidth;
    property ChangeDelay;
    property CheckImageKind;
    property ClipboardFormats;
    property Color;
    property Colors;
    property Constraints;
    property Ctl3D;
    property CustomCheckImages;
    property DefaultNodeHeight;
    property DefaultPasteMode;
    property DragCursor;
    property DragHeight;
    property DragKind;
    property DragImageKind;
    property DragMode;
    property DragOperations;
    property DragType;
    property DragWidth;
    property DrawSelectionMode;
    property EditDelay;
    property Enabled;
    property Font;
    property Header;
    property HintAnimation;
    property HintMode;
    property HotCursor;
    property Images;
    property IncrementalSearch;
    property IncrementalSearchDirection;
    property IncrementalSearchStart;
    property IncrementalSearchTimeout;
    property Indent;
    property LineMode;
    property LineStyle;
    property Margin;
    property NodeAlignment;
    property NodeDataSize;
    property ParentBiDiMode;
    property ParentColor default False;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property RootNodeCount;
    property ScrollBarOptions;
    property SelectionCurveRadius;
    property ShowHint;
    property StateImages;
    property TabOrder;
    property TabStop default True;
    property TextMargin;
    property TreeOptions: TVirtualTreeOptions read GetOptions write SetOptions;
    property Visible;
    property WantTabs;

    property OnAfterCellPaint;
    property OnAfterItemErase;
    property OnAfterItemPaint;
    property OnAfterPaint;
    property OnBeforeCellPaint;
    property OnBeforeItemErase;
    property OnBeforeItemPaint;
    property OnBeforePaint;
    property OnChange;
    property OnChecked;
    property OnChecking;
    property OnClick;
    property OnCollapsed;
    property OnCollapsing;
    property OnColumnClick;
    property OnColumnDblClick;
    property OnColumnResize;
    property OnCompareNodes;
    {$ifdef COMPILER_5_UP}
      property OnContextPopup;
    {$endif COMPILER_5_UP}
    property OnCreateDataObject;
    property OnCreateDragManager;
    property OnCreateEditor;
    property OnDblClick;
    property OnDragAllowed;
    property OnDragOver;
    property OnDragDrop;
    property OnDrawHint;
    property OnDrawNode;
    property OnEdited;
    property OnEditing;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnExpanded;
    property OnExpanding;
    property OnFocusChanged;
    property OnFocusChanging;
    property OnFreeNode;
    property OnGetCursor;
    property OnGetHeaderCursor;
    property OnGetHelpContext;
    property OnGetHintSize;
    property OnGetImageIndex;
    property OnGetLineStyle;
    property OnGetNodeDataSize;
    property OnGetNodeWidth;
    property OnGetPopupMenu;
    property OnGetUserClipboardFormats;
    property OnHeaderClick;
    property OnHeaderDblClick;
    property OnHeaderDragged;
    property OnHeaderDragging;
    property OnHeaderDraw;
    property OnHeaderMouseDown;
    property OnHeaderMouseMove;
    property OnHeaderMouseUp;
    property OnHotChange;
    property OnIncrementalSearch;
    property OnInitChildren;
    property OnInitNode;
    property OnKeyAction;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnLoadNode;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnNodeCopied;
    property OnNodeCopying;
    property OnNodeMoved;
    property OnNodeMoving;
    property OnPaintBackground;
    property OnRenderOLEData;
    property OnResetNode;
    property OnResize;
    property OnSaveNode;
    property OnScroll;
    property OnStartDock;
    property OnStructureChange;
    property OnUpdating;
  end;

type
  // Describes the mode how to blend pixels.
  TBlendMode = (
    bmConstantAlpha,         // apply given constant alpha
    bmPerPixelAlpha,         // use alpha value of the source pixel
    bmMasterAlpha,           // use alpha value of source pixel and multiply it with the constant alpha value
    bmConstantAlphaAndColor  // blend the destination color with the given constant color und the constant alpha value
  );

// OLE Clipboard and drag'n drop helper
procedure EnumerateVTClipboardFormats(TreeClass: TVirtualTreeClass; const List: TStrings); 
function GetVTClipboardFormatDescription(AFormat: Word): string;
procedure RegisterVTClipboardFormat(AFormat: Word; TreeClass: TVirtualTreeClass; Priority: Cardinal); overload;
function RegisterVTClipboardFormat(Description: string; TreeClass: TVirtualTreeClass; Priority: Cardinal;
  tymed: Integer = TYMED_HGLOBAL; ptd: PDVTargetDevice = nil; dwAspect: Integer = DVASPECT_CONTENT;
  lindex: Integer = -1): Word; overload;

// utility routines
procedure AlphaBlend(Source, Destination: HDC; R: TRect; Target: TPoint; Mode: TBlendMode; ConstantAlpha, Bias: Integer);
procedure DrawTextW(DC: HDC; lpString: PWideChar; nCount: Integer; var lpRect: TRect; uFormat: Cardinal;
  AdjustRight: Boolean);
function ShortenString(DC: HDC; const S: WideString; Width: Integer; RTL: Boolean;
  EllipsisWidth: Integer = 0): WideString;
function TreeFromNode(Node: PVirtualNode): TBaseVirtualTree;

//----------------------------------------------------------------------------------------------------------------------

Procedure Register;

implementation


{$R VirtualTrees.res}

uses
  Consts, Math,
  AxCtrls,   // TOLEStream
  CommCtrl,  // image list stuff
  {$ifdef UseFlatScrollbars}
    FlatSB,    // wrapper for systems without flat SB support
  {$endif UseFlatScrollbars}
  SyncObjs,  // for the critical section
  MMSystem,  // for animation timer (does not include further resources)
  TypInfo,   // for migration stuff
  ActnList,
  StdActns;  // for standard action support

Procedure Register;
Begin
  RegisterComponents('Virtual Controls', [TBaseVirtualTree, TVirtualStringTree, TVirtualDrawTree]);
End;
  
resourcestring
  // Localizable strings.
  SEditLinkIsNil = 'Edit link must not be nil.';
  SWrongMoveError = 'Target node cannot be a child node of the node to be moved.';
  SWrongStreamFormat = 'Unable to load tree structure, the format is wrong.';
  SWrongStreamVersion = 'Unable to load tree structure, the version is unknown.';
  SStreamTooSmall = 'Unable to load tree structure, not enough data available.';
  SCorruptStream1 = 'Stream data corrupt. A node''s anchor chunk is missing.';
  SCorruptStream2 = 'Stream data corrupt. Unexpected data after node''s end position.';
  SClipboardFailed = 'Clipboard operation failed.';
  SCannotSetUserData = 'Cannot set initial user data because there is not enough user data space allocated.';

const
  ClipboardStates = [tsCopyPending, tsCutPending];
  DefaultScrollUpdateFlags = [suoRepaintHeader, suoRepaintScrollbars, suoScrollClientArea, suoUpdateNCArea];
  MinimumTimerInterval = 1; // minimum resolution for timeGetTime
  TreeNodeSize = (SizeOf(TVirtualNode) + 3) and not 3; // used for node allocation and access to internal data

  // Lookup to quickly convert a specific check state into its pressed counterpart and vice versa. 
  PressedState: array[TCheckState] of TCheckState = (
    csUncheckedPressed, csUncheckedPressed, csCheckedPressed, csCheckedPressed, csMixedPressed, csMixedPressed
  );
  UnpressedState: array[TCheckState] of TCheckState = (
    csUncheckedNormal, csUncheckedNormal, csCheckedNormal, csCheckedNormal, csMixedNormal, csMixedNormal
  );

var
  StandardOLEFormat: TFormatEtc = (
    // Format must later be set.
    cfFormat: 0;
    // No specific target device to render on.
    ptd: nil;
    // Normal content to render.
    dwAspect: DVASPECT_CONTENT;
    // No specific page of multipage data (we don't use multipage data by default).
    lindex: -1;
    // Acceptable storage formats are IStream and global memory. The first is preferred.
    tymed: TYMED_ISTREAM or TYMED_HGLOBAL;
  );


type // streaming support
  TMagicID = array[0..5] of WideChar;

  TChunkHeader = record
    ChunkType,
    ChunkSize: Integer;      // contains the size of the chunk excluding the header
  end;

  // base information about a node
  TBaseChunkBody = packed record
    ChildCount,
    NodeHeight: Cardinal;
    States: TVirtualNodeStates;
    Align: Byte;
    CheckState: TCheckState;
    CheckType: TCheckType;
    Reserved: Cardinal;
  end;

  TBaseChunk = packed record
    Header: TChunkHeader;
    Body: TBaseChunkBody;
  end;

  // Internally used data for animations.
  TToggleAnimationData = record
    Expand: Boolean;    // if true then expanding is in progress
    Window: HWND;       // copy of the tree's window handle
    DC: HDC;            // the DC of the window to erase unconvered parts
    Brush: HBRUSH;      // the brush to be used to erase uncovered parts
    R: TRect;           // the scroll rectangle
  end;

const
  MagicID: TMagicID = (#$2045, 'V', 'T', WideChar(VTTreeStreamVersion), ' ', #$2046);

  // chunk IDs
  NodeChunk = 1;
  BaseChunk = 2;        // chunk containing node state, check state, child node count etc.
                        // this chunk is immediately followed by all child nodes
  CaptionChunk = 3;     // used by the string tree to store a node's caption
  UserChunk = 4;        // used for data supplied by the application

  {$ifdef UseFlatScrollbars}
    ScrollBarProp: array[TScrollBarStyle] of Integer = (
      FSB_REGULAR_MODE,
      FSB_FLAT_MODE,
      FSB_ENCARTA_MODE
    );
  {$endif}
  
  RTLFlag: array[Boolean] of Integer = (0, ETO_RTLREADING);
  AlignmentToDrawFlag: array[TAlignment] of Cardinal = (DT_LEFT, DT_RIGHT, DT_CENTER);

  WideNull = WideChar(#0);
  WideCR = WideChar(#13);
  WideLF = WideChar(#10);
  WideLineSeparator = WideChar(#2028);

type
  // internal worker thread
  TWorkerThread = class(TThread)
  private
    FCurrentTree: TBaseVirtualTree;
    FWaiterList: TThreadList;
    FRefCount: Cardinal;
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspended: Boolean);
    destructor Destroy; override;

    procedure AddTree(Tree: TBaseVirtualTree);
    procedure RemoveTree(Tree: TBaseVirtualTree);
  end;

  // Helper classes to speed up rendering text formats for clipboard and drag'n drop transfers.
  TBufferedString = class
  private
    FStart,
    FPosition,
    FEnd: PChar;
    function GetAsString: string;
  public
    destructor Destroy; override;

    procedure Add(const S: string);
    procedure AddNewLine;

    property AsString: string read GetAsString;
  end;

  TWideBufferedString = class
  private
    FStart,
    FPosition,
    FEnd: PWideChar;
    function GetAsString: WideString;
  public
    destructor Destroy; override;

    procedure Add(const S: WideString);
    procedure AddNewLine;

    property AsString: WideString read GetAsString;
  end;

var
  WorkerThread: TWorkerThread;
  WorkEvent: THandle;
  Watcher: TCriticalSection;
  LightCheckImages,          // global light check images
  DarkCheckImages,           // global heavy check images
  LightTickImages,           // global light tick images
  DarkTickImages,            // global heavy check images
  FlatImages,                // global flat check images
  XPImages,                  // global XP style check images
  UtilityImages: TImageList; // some small additional images (e.g for header dragging)
  IsWinNT: Boolean;          // necessary to fix a bug in Win95/WinME regarding non-client area region intersection
                             // and to allow for check of system dependent hint animation
  IsWin2K: Boolean;          // nessary to provide correct string shortage
  IsWinXP: Boolean;          // necessary to paint the correct frame for the string edit  

  {$ifndef COMPILER_5_UP}
    HintFont: TFont;         // in Delphi 4 there is no TScreen.HintFont yet
  {$endif COMPILER_5_UP}

//----------------------------------------------------------------------------------------------------------------------

{$ifndef COMPILER_6_UP}

  procedure RaiseLastOSError;

  begin
    RaiseLastWin32Error;
  end;

{$endif COMPILER_6_UP}

//----------------- TClipboardFormats ----------------------------------------------------------------------------------

type
  PClipboardFormatListEntry = ^TClipboardFormatListEntry;
  TClipboardFormatListEntry = record
    Description: string;               // The string used to register the format with Windows.
    TreeClass: TVirtualTreeClass;      // The tree class which supports rendering this format.
    Priority: Cardinal;                // Number which determines the order of formats used in IDataObject.
    FormatEtc: TFormatEtc;             // The definition of the format in the IDataObject.
  end;

  TClipboardFormatList = class
  private
    FList: TList;
    procedure Sort;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(FormatString: string; AClass: TVirtualTreeClass; Priority: Cardinal; AFormatEtc: TFormatEtc);
    procedure Clear;
    procedure EnumerateFormats(TreeClass: TVirtualTreeClass; var Formats: TFormatEtcArray); overload;
    procedure EnumerateFormats(TreeClass: TVirtualTreeClass; const Formats: TStrings); overload;
    function FindFormat(FormatString: string; var Fmt: Word): TVirtualTreeClass; overload;
    function FindFormat(Fmt: Word; var Description: string): TVirtualTreeClass; overload;
  end;

var
  InternalClipboardFormats: TClipboardFormatList;

//----------------------------------------------------------------------------------------------------------------------

constructor TClipboardFormatList.Create;

begin
  FList := TList.Create;
end;

//----------------------------------------------------------------------------------------------------------------------

destructor TClipboardFormatList.Destroy;

begin
  Clear;
  FList.Free;
  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TClipboardFormatList.Sort;

// Sorts all entry for priority (increasing priority value).

  //--------------- local function --------------------------------------------

  procedure QuickSort(L, R: Integer);

  var
    I, J: Integer;
    P, T: PClipboardFormatListEntry;

  begin
    repeat
      I := L;
      J := R;
      P := FList[(L + R) shr 1];
      repeat
        while PClipboardFormatListEntry(FList[I]).Priority < P.Priority do
          Inc(I);
        while PClipboardFormatListEntry(Flist[J]).Priority > P.Priority do
          Dec(J);
        if I <= J then
        begin
          T := Flist[I];
          FList[I] := FList[J];
          FList[J] := T;
          Inc(I);
          Dec(J);
        end;
      until I > J;
      if L < J then
        QuickSort(L, J);
      L := I;
    until I >= R;
  end;

  //--------------- end local function ----------------------------------------

begin
  if FList.Count > 1 then
    QuickSort(0, FList.Count - 1);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TClipboardFormatList.Add(FormatString: string; AClass: TVirtualTreeClass; Priority: Cardinal;
  AFormatEtc: TFormatEtc);

// Adds the given data to the internal list. The priority value is used to sort formats for importance. Larger priority
// values mean less priority.

var
  Entry: PClipboardFormatListEntry;

begin
  New(Entry);
  Entry.Description := FormatString;
  Entry.TreeClass := AClass;
  Entry.Priority := Priority;
  Entry.FormatEtc := AFormatEtc;
  FList.Add(Entry);

  Sort;
end;

//----------------------------------------------------------------------------------------------------------------------


procedure TClipboardFormatList.Clear;

var
  I: Integer;

begin
  for I := 0 to FList.Count - 1 do
    Dispose(PClipboardFormatListEntry(FList[I]));
  FList.Clear;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TClipboardFormatList.EnumerateFormats(TreeClass: TVirtualTreeClass; var Formats: TFormatEtcArray);

// Returns a list of format records for the given class.

var
  I, Count: Integer;
  Entry: PClipboardFormatListEntry;

begin
  SetLength(Formats, FList.Count);
  Count := 0;
  for I := 0 to FList.Count - 1 do
  begin
    Entry := FList[I];
    if TreeClass.InheritsFrom(Entry.TreeClass) then
    begin
      // The list could change before we use the FormatEtc so it is best not to pass a pointer to the true FormatEtc
      // structure. Instead make a copy and send that.
      Formats[Count] := Entry.FormatEtc;
      Inc(Count);
    end;
  end;
  SetLength(Formats, Count);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TClipboardFormatList.EnumerateFormats(TreeClass: TVirtualTreeClass; const Formats: TStrings); 

// Returns a list of format descriptions for the given class.

var
  I: Integer;
  Entry: PClipboardFormatListEntry;

begin
  for I := 0 to FList.Count - 1 do
  begin
    Entry := FList[I];
    if TreeClass.InheritsFrom(Entry.TreeClass) then
      Formats.Add(Entry.Description);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TClipboardFormatList.FindFormat(FormatString: string; var Fmt: Word): TVirtualTreeClass;

var
  I: Integer;
  Entry: PClipboardFormatListEntry;

begin
  Result := nil;
  for I := FList.Count - 1 downto 0 do
  begin
    Entry := FList[I];
    if CompareText(Entry.Description, FormatString) = 0 then
    begin
      Result := Entry.TreeClass;
      Fmt := Entry.FormatEtc.cfFormat;
      Break;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TClipboardFormatList.FindFormat(Fmt: Word; var Description: string): TVirtualTreeClass;

var
  I: Integer;
  Entry: PClipboardFormatListEntry;

begin
  Result := nil;
  for I := FList.Count - 1 downto 0 do
  begin
    Entry := FList[I];
    if Entry.FormatEtc.cfFormat = Fmt then
    begin
      Result := Entry.TreeClass;
      Description := Entry.Description;
      Break;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

type
  TClipboardFormatEntry = record
    ID: Word;
    Description: string;
  end;

var
  ClipboardDescriptions: array [1..CF_MAX - 1] of TClipboardFormatEntry = (
    (ID: CF_TEXT; Description: 'Plain text'),
    (ID: CF_BITMAP; Description: 'Windows bitmap'),
    (ID: CF_METAFILEPICT; Description: 'Windows metafile'),
    (ID: CF_SYLK; Description: 'Symbolic link'),
    (ID: CF_DIF; Description: 'Data interchange format'),
    (ID: CF_TIFF; Description: 'Tiff image'),
    (ID: CF_OEMTEXT; Description: 'OEM text'),
    (ID: CF_DIB; Description: 'DIB image'),
    (ID: CF_PALETTE; Description: 'Palette data'),
    (ID: CF_PENDATA; Description: 'Pen data'),
    (ID: CF_RIFF; Description: 'Riff audio data'),
    (ID: CF_WAVE; Description: 'Wav audio data'),
    (ID: CF_UNICODETEXT; Description: 'Unicode text'),
    (ID: CF_ENHMETAFILE; Description: 'Enhanced metafile image'),
    (ID: CF_HDROP; Description: 'File name(s)'),
    (ID: CF_LOCALE; Description: 'Locale descriptor')
  );

//----------------------------------------------------------------------------------------------------------------------

procedure EnumerateVTClipboardFormats(TreeClass: TVirtualTreeClass; const List: TStrings);

begin
  InternalClipboardFormats.EnumerateFormats(TreeClass, List);
end;

//----------------------------------------------------------------------------------------------------------------------

function GetVTClipboardFormatDescription(AFormat: Word): string;

begin
  if InternalClipboardFormats.FindFormat(AFormat, Result) = nil then
    Result := '';
end;

//----------------------------------------------------------------------------------------------------------------------

procedure RegisterVTClipboardFormat(AFormat: Word; TreeClass: TVirtualTreeClass; Priority: Cardinal);

// Registers the given clipboard format for the given TreeClass.

var
  I: Integer;
  Buffer: array[0..2048] of Char;
  FormatEtc: TFormatEtc;

begin
  // Assumes a HGlobal format.
  FormatEtc.cfFormat := AFormat;
  FormatEtc.ptd := nil;
  FormatEtc.dwAspect := DVASPECT_CONTENT;
  FormatEtc.lindex := -1;
  FormatEtc.tymed := TYMED_HGLOBAL;

  // Determine description string of the given format. For predefined formats we need the lookup table because they
  // don't have a description string. For registered formats the description string is the string which was used
  // to register them.
  if AFormat < CF_MAX then
  begin
    for I := 1 to High(ClipboardDescriptions) do
      if ClipboardDescriptions[I].ID = AFormat then
      begin
        InternalClipboardFormats.Add(ClipboardDescriptions[I].Description, TreeClass, Priority, FormatEtc);
        Break;
      end;
  end
  else
  begin
    GetClipboardFormatName(AFormat, Buffer, Length(Buffer));
    InternalClipboardFormats.Add(Buffer, TreeClass, Priority, FormatEtc);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function RegisterVTClipboardFormat(Description: string; TreeClass: TVirtualTreeClass; Priority: Cardinal;
  tymed: Integer = TYMED_HGLOBAL; ptd: PDVTargetDevice = nil; dwAspect: Integer = DVASPECT_CONTENT;
  lindex: Integer = -1): Word; 

// Alternative method to register a certain clipboard format for a given tree class. Registration with the
// clipboard is done here too and the assigned ID returned by the function.
// tymed may contain or'ed TYMED constants which allows to register several storage formats for one clipboard format.

var
  FormatEtc: TFormatEtc;

begin
  Result := RegisterClipboardFormat(PChar(Description));
  FormatEtc.cfFormat := Result;
  FormatEtc.ptd := ptd;
  FormatEtc.dwAspect := dwAspect;
  FormatEtc.lindex := lindex;
  FormatEtc.tymed := tymed;
  InternalClipboardFormats.Add(Description, TreeClass, Priority, FormatEtc);
end;

//----------------- utility functions ----------------------------------------------------------------------------------

procedure ShowError(Msg: WideString; HelpContext: Integer);

begin
  raise EVirtualTreeError.CreateHelp(Msg, HelpContext);
end;

//----------------------------------------------------------------------------------------------------------------------

function TreeFromNode(Node: PVirtualNode): TBaseVirtualTree;

// Returns the tree the node currently belongs to or nil if the node is not attached to a tree.

begin
  Assert(Assigned(Node), 'Node must not be nil.');

  // The root node is marked by having its NextSibling (and PrevSibling) pointing to itself.
  while Assigned(Node) and (Node.NextSibling <> Node) do
    Node := Node.Parent;
  if Assigned(Node) then
    Result := TBaseVirtualTree(Node.Parent)
  else
    Result := nil;
end;

//----------------------------------------------------------------------------------------------------------------------

function OrderRect(const R: TRect): TRect;

// Converts the incoming rectangle so that left and top are always less than or equal to right and bottom.

begin
  if R.Left < R.Right then
  begin
    Result.Left := R.Left;
    Result.Right := R.Right;
  end
  else
  begin
    Result.Left := R.Right;
    Result.Right := R.Left;
  end;
  if R.Top < R.Bottom then
  begin
    Result.Top := R.Top;
    Result.Bottom := R.Bottom;
  end
  else
  begin
    Result.Top := R.Bottom;
    Result.Bottom := R.Top;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure QuickSort(const TheArray: TNodeArray; L, R: Integer);

var
  I, J: Integer;
  P, T: Pointer;

begin
  repeat
    I := L;
    J := R;
    P := TheArray[(L + R) shr 1];
    repeat
      while Cardinal(TheArray[I]) < Cardinal(P) do
        Inc(I);
      while Cardinal(TheArray[J]) > Cardinal(P) do
        Dec(J);
      if I <= J then
      begin
        T := TheArray[I];
        TheArray[I] := TheArray[J];
        TheArray[J] := T;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then
      QuickSort(TheArray, L, J);
    L := I;
  until I >= R;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure DrawTextW(DC: HDC; lpString: PWideChar; nCount: Integer; var lpRect: TRect; uFormat: Cardinal;
  AdjustRight: Boolean);

// This procedure implements a subset of Window's DrawText API for Unicode which is not available for
// Windows 9x. For a description of the parameters see DrawText in the online help.
// Supported flags are currently:
//   - DT_LEFT
//   - DT_TOP
//   - DT_CALCRECT
//   - DT_NOCLIP
//   - DT_RTLREADING
//   - DT_SINGLELINE
//   - DT_VCENTER
// Differences to the DrawTextW Windows API:
//   - The additional parameter AdjustRight determines whether to adjust the right border of the given rectangle to
//     accomodate the largest line in the text. It has only a meaning if also DT_CALCRECT is specified.

var
  Head, Tail: PWideChar;
  Size: TSize;
  MaxWidth: Integer;
  TextOutFlags: Integer;
  TextAlign: Cardinal;
  TM: TTextMetric;
  TextHeight: Integer;
  LineRect: TRect;
  TextPosY,
  TextPosX: Integer;

  CalculateRect: Boolean;

begin
  // Prepare some work variables.
  MaxWidth := 0;
  Head := lpString;
  GetTextMetrics(DC, TM);
  TextHeight := TM.tmHeight;
  if uFormat and DT_SINGLELINE <> 0 then
    LineRect := lpRect
  else
    LineRect := Rect(lpRect.Left, lpRect.Top, lpRect.Right, lpRect.Top + TextHeight);

  CalculateRect := uFormat and DT_CALCRECT <> 0;

  // Prepare text output.
  TextOutFlags := 0;
  if uFormat and DT_NOCLIP = 0 then
    TextOutFlags := TextOutFlags or ETO_CLIPPED;
  if uFormat and DT_RTLREADING <> 0 then
    TextOutFlags := TextOutFlags or ETO_RTLREADING;

  // Determine horizontal and vertical text alignment.
  TextAlign := TA_LEFT or TA_TOP;
  TextPosX := lpRect.Left;
  if uFormat and DT_RIGHT <> 0 then
  begin
    TextAlign := TextAlign or TA_RIGHT and not TA_LEFT;
    TextPosX := lpRect.Right;
  end
  else
    if uFormat and DT_CENTER <> 0 then
    begin
      TextAlign := TextAlign or TA_CENTER and not TA_LEFT;
      TextPosX := (lpRect.Left + lpRect.Right) div 2;
    end;

  TextPosY := lpRect.Top;
  if uFormat and DT_VCENTER <> 0 then
  begin
    // Note: vertical alignment does only work with single line text ouput!
    TextPosY := (lpRect.Top + lpRect.Bottom - TextHeight) div 2;
  end;
  SetTextAlign(DC, TextAlign);

  if uFormat and DT_SINGLELINE <> 0 then
  begin
    if CalculateRect then
    begin
      GetTextExtentPoint32W(DC, Head, nCount, Size);
      if Size.cx > MaxWidth then
        MaxWidth := Size.cx;
    end
    else
      ExtTextOutW(DC, TextPosX, TextPosY, TextOutFlags, @LineRect, Head, nCount, nil);
    OffsetRect(LineRect, 0, TextHeight);
  end
  else
  begin
    while (nCount > 0) and (Head^ <> WideNull) do
    begin
      Tail := Head;
      // Look for the end of the current line. A line is finished either by the string end or a line break.
      while (nCount > 0) and not (Tail^ in [WideNull, WideCR, WideLF]) and (Tail^ <> WideLineSeparator) do
      begin
        Inc(Tail);
        Dec(nCount);
      end;

      if CalculateRect then
      begin
        GetTextExtentPoint32W(DC, Head, Tail - Head, Size);
        if Size.cx > MaxWidth then
          MaxWidth := Size.cx;
      end
      else
        ExtTextOutW(DC, TextPosX, LineRect.Top, TextOutFlags, @LineRect, Head, Tail - Head, nil);
      OffsetRect(LineRect, 0, TextHeight);

      // Get out of the loop if the rectangle is filled up.
      if (nCount = 0) or (not CalculateRect and (LineRect.Top >= lpRect.Bottom)) then
        Break;

      if (nCount > 0) and (Tail^ = WideCR) or (Tail^ = WideLineSeparator) then
      begin
        Inc(Tail);
        Dec(nCount);
      end;

      if (nCount > 0) and (Tail^ = WideLF) then
      begin
        Inc(Tail);
        Dec(nCount);
      end;
      Head := Tail;
    end;
  end;
  
  if CalculateRect then
  begin
    if AdjustRight then
      lpRect.Right := lpRect.Left + MaxWidth;
    lpRect.Bottom := LineRect.Top;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function ShortenString(DC: HDC; const S: WideString; Width: Integer; RTL: Boolean;
  EllipsisWidth: Integer = 0): WideString;

// Adjusts the given string S so that it fits into the given width. EllipsisWidth gives the width of
// the three points to be added to the shorted string. If this value is 0 then it will be determined implicitely.
// For higher speed (and multiple entries to be shorted) specify this value explicitely.
// RTL determines if right-to-left reading is active, which is needed to put the ellipsisis on the correct side.
// Note: It is assumed that the string really needs shortage. Check this in advance.

var
  Size: TSize;
  Len: Integer;
  L, H, N, W: Integer;

begin
  Len := Length(S);
  if (Len = 0) or (Width <= 0) then
    Result := ''
  else
  begin
    // Determine width of triple point using the current DC settings (if not already done).
    if EllipsisWidth = 0 then
    begin
      GetTextExtentPoint32W(DC, '...', 3, Size);
      EllipsisWidth := Size.cx;
    end;

    if Width <= EllipsisWidth then
      Result := ''
    else
    begin
      // Do a binary search for the optimal string length which fits into the given width.
      L := 0;
      H := Len;
      N := 0;
      while L <= H do
      begin
        N := (L + H) shr 1;
        GetTextExtentPoint32W(DC, PWideChar(S), N, Size);
        W := Size.cx + EllipsisWidth;
        if W < Width then
          L := N + 1
        else
        begin
          H := N - 1;
          if W = Width then
            L := N;
        end;
      end;

      // Windows 2000 automatically switches the order in the string. For every other system we have to take care.
      if IsWin2K or not RTL then
        Result := Copy(S, 1, N - 1) + '...'
      else
        Result := '...' + Copy(S, 1, N - 1);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure FillDragRectangles(DragWidth, DragHeight, DeltaX, DeltaY: Integer; var RClip, RScroll, RSamp1, RSamp2, RDraw1,
  RDraw2: TRect);

// Fills the given rectangles with values which can be used while dragging around an image
// (used in DragMove of the drag manager and DragTo of the header columns).

begin
  // ScrollDC limits
  RClip := Rect(0, 0, DragWidth, DragHeight);
  if DeltaX > 0 then
  begin
    // move to the left
    if DeltaY = 0 then
    begin
      // move only to the left
      // background movement
      RScroll := Rect(0, 0, DragWidth - DeltaX, DragHeight);
      RSamp1 := Rect(0, 0, DeltaX, DragHeight);
      RDraw1 := Rect(DragWidth - DeltaX, 0, DeltaX, DragHeight);
    end
    else
      if DeltaY < 0 then
      begin
        // move to bottom left
        RScroll := Rect(0, -DeltaY, DragWidth - DeltaX, DragHeight);
        RSamp1 := Rect(0, 0, DeltaX, DragHeight);
        RSamp2 := Rect(DeltaX, DragHeight + DeltaY, DragWidth - DeltaX, -DeltaY);
        RDraw1 := Rect(0, 0, DragWidth - DeltaX, -DeltaY);
        RDraw2 := Rect(DragWidth - DeltaX, 0, DeltaX, DragHeight);
      end
      else
      begin
        // move to upper left
        RScroll := Rect(0, 0, DragWidth - DeltaX, DragHeight - DeltaY);
        RSamp1 := Rect(0, 0, DeltaX, DragHeight);
        RSamp2 := Rect(DeltaX, 0, DragWidth - DeltaX, DeltaY);
        RDraw1 := Rect(0, DragHeight - DeltaY, DragWidth - DeltaX, DeltaY);
        RDraw2 := Rect(DragWidth - DeltaX, 0, DeltaX, DragHeight);
      end;
  end
  else
    if DeltaX = 0 then
    begin
      // vertical movement only
      if DeltaY < 0 then
      begin
        // move downwards
        RScroll := Rect(0, -DeltaY, DragWidth, DragHeight);
        RSamp2 := Rect(0, DragHeight + DeltaY, DragWidth, -DeltaY);
        RDraw2 := Rect(0, 0, DragWidth, -DeltaY);
      end
      else
      begin
        // move upwards
        RScroll := Rect(0, 0, DragWidth, DragHeight - DeltaY);
        RSamp2 := Rect(0, 0, DragWidth, DeltaY);
        RDraw2 := Rect(0, DragHeight - DeltaY, DragWidth, DeltaY);
      end;
    end
    else
    begin
      // move to the right
      if DeltaY > 0 then
      begin
        // move up right
        RScroll := Rect(-DeltaX, 0, DragWidth, DragHeight);
        RSamp1 := Rect(0, 0, DragWidth + DeltaX, DeltaY);
        RSamp2 := Rect(DragWidth + DeltaX, 0, -DeltaX, DragHeight);
        RDraw1 := Rect(0, 0, -DeltaX, DragHeight);
        RDraw2 := Rect(-DeltaX, DragHeight - DeltaY, DragWidth + DeltaX, DeltaY);
      end
      else
        if DeltaY = 0 then
        begin
          // to the right only
          RScroll := Rect(-DeltaX, 0, DragWidth, DragHeight);
          RSamp1 := Rect(DragWidth + DeltaX, 0, -DeltaX, DragHeight);
          RDraw1 := Rect(0, 0, -DeltaX, DragHeight);
        end
        else
        begin
          // move down right
          RScroll := Rect(-DeltaX, -DeltaY, DragWidth, DragHeight);
          RSamp1 := Rect(0, DragHeight + DeltaY, DragWidth + DeltaX, -DeltaY);
          RSamp2 := Rect(DragWidth + DeltaX, 0, -DeltaX, DragHeight);
          RDraw1 := Rect(0, 0, -DeltaX, DragHeight);
          RDraw2 := Rect(-DeltaX, 0, DragWidth + DeltaX, -DeltaY);
        end;
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure AlphaBlendLineConstant(Source, Destination: Pointer; Count: Integer; ConstantAlpha, Bias: Integer);

// Blends a line of Count pixels from Source to Destination using a constant alpha value.
// The layout of a pixel must be BGRA where A is ignored (but is calculated as the other components).
// ConstantAlpha must be in the range 0..255 where 0 means totally transparent (destination pixel only)
// and 255 totally opaque (source pixel only).
// Bias is an additional value which gets added to every component and must be in the range -128..127
//
// EAX contains Source
// EDX contains Destination
// ECX contains Count
// ConstantAlpha and Bias are on the stack

asm
        PUSH    ESI                    // save used registers
        PUSH    EDI

        MOV     ESI, EAX               // ESI becomes the actual source pointer
        MOV     EDI, EDX               // EDI becomes the actual target pointer

        // Load MM6 with the constant alpha value (replicate it for every component).
        // Expand it to word size.
        MOV     EAX, [ConstantAlpha]
        DB      $0F, $6E, $F0          /// MOVD      MM6, EAX
        DB      $0F, $61, $F6          /// PUNPCKLWD MM6, MM6
        DB      $0F, $62, $F6          /// PUNPCKLDQ MM6, MM6

        // Load MM5 with the bias value.
        MOV     EAX, [Bias]
        DB      $0F, $6E, $E8          /// MOVD      MM5, EAX
        DB      $0F, $61, $ED          /// PUNPCKLWD MM5, MM5
        DB      $0F, $62, $ED          /// PUNPCKLDQ MM5, MM5

        // Load MM4 with 128 to allow for saturated biasing.
        MOV     EAX, 128
        DB      $0F, $6E, $E0          /// MOVD      MM4, EAX
        DB      $0F, $61, $E4          /// PUNPCKLWD MM4, MM4
        DB      $0F, $62, $E4          /// PUNPCKLDQ MM4, MM4

@1:     // The pixel loop calculates an entire pixel in one run.
        // Note: The pixel byte values are expanded into the higher bytes of a word due
        //       to the way unpacking works. We compensate for this with an extra shift.
        DB      $0F, $EF, $C0          /// PXOR      MM0, MM0,   clear source pixel register for unpacking
        DB      $0F, $60, $06          /// PUNPCKLBW MM0, [ESI], unpack source pixel byte values into words
        DB      $0F, $71, $D0, $08     /// PSRLW     MM0, 8,     move higher bytes to lower bytes
        DB      $0F, $EF, $C9          /// PXOR      MM1, MM1,   clear target pixel register for unpacking
        DB      $0F, $60, $0F          /// PUNPCKLBW MM1, [EDI], unpack target pixel byte values into words
        DB      $0F, $6F, $D1          /// MOVQ      MM2, MM1,   make a copy of the shifted values, we need them again
        DB      $0F, $71, $D1, $08     /// PSRLW     MM1, 8,     move higher bytes to lower bytes

        // calculation is: target = (alpha * (source - target) + 256 * target) / 256
        DB      $0F, $F9, $C1          /// PSUBW     MM0, MM1,   source - target
        DB      $0F, $D5, $C6          /// PMULLW    MM0, MM6,   alpha * (source - target)
        DB      $0F, $FD, $C2          /// PADDW     MM0, MM2,   add target (in shifted form)
        DB      $0F, $71, $D0, $08     /// PSRLW     MM0, 8,     divide by 256

        // Bias is accounted for by conversion of range 0..255 to -128..127,
        // doing a saturated add and convert back to 0..255.
        DB      $0F, $F9, $C4          /// PSUBW     MM0, MM4
        DB      $0F, $ED, $C5          /// PADDSW    MM0, MM5
        DB      $0F, $FD, $C4          /// PADDW     MM0, MM4
        DB      $0F, $67, $C0          /// PACKUSWB  MM0, MM0,   convert words to bytes with saturation
        DB      $0F, $7E, $07          /// MOVD      [EDI], MM0, store the result
@3:
        ADD     ESI, 4
        ADD     EDI, 4
        DEC     ECX
        JNZ     @1
        POP     EDI
        POP     ESI
end;

//----------------------------------------------------------------------------------------------------------------------

procedure AlphaBlendLinePerPixel(Source, Destination: Pointer; Count, Bias: Integer);

// Blends a line of Count pixels from Source to Destination using the alpha value of the source pixels.
// The layout of a pixel must be BGRA.
// Bias is an additional value which gets added to every component and must be in the range -128..127
//
// EAX contains Source
// EDX contains Destination
// ECX contains Count
// Bias is on the stack

asm
        PUSH    ESI                    // save used registers
        PUSH    EDI

        MOV     ESI, EAX               // ESI becomes the actual source pointer
        MOV     EDI, EDX               // EDI becomes the actual target pointer

        // Load MM5 with the bias value.
        MOV     EAX, [Bias]
        DB      $0F, $6E, $E8          /// MOVD      MM5, EAX
        DB      $0F, $61, $ED          /// PUNPCKLWD MM5, MM5
        DB      $0F, $62, $ED          /// PUNPCKLDQ MM5, MM5

        // Load MM4 with 128 to allow for saturated biasing.
        MOV     EAX, 128
        DB      $0F, $6E, $E0          /// MOVD      MM4, EAX
        DB      $0F, $61, $E4          /// PUNPCKLWD MM4, MM4
        DB      $0F, $62, $E4          /// PUNPCKLDQ MM4, MM4

@1:     // The pixel loop calculates an entire pixel in one run.
        // Note: The pixel byte values are expanded into the higher bytes of a word due
        //       to the way unpacking works. We compensate for this with an extra shift.
        DB      $0F, $EF, $C0          /// PXOR      MM0, MM0,   clear source pixel register for unpacking
        DB      $0F, $60, $06          /// PUNPCKLBW MM0, [ESI], unpack source pixel byte values into words
        DB      $0F, $71, $D0, $08     /// PSRLW     MM0, 8,     move higher bytes to lower bytes
        DB      $0F, $EF, $C9          /// PXOR      MM1, MM1,   clear target pixel register for unpacking
        DB      $0F, $60, $0F          /// PUNPCKLBW MM1, [EDI], unpack target pixel byte values into words
        DB      $0F, $6F, $D1          /// MOVQ      MM2, MM1,   make a copy of the shifted values, we need them again
        DB      $0F, $71, $D1, $08     /// PSRLW     MM1, 8,     move higher bytes to lower bytes

        // Load MM6 with the source alpha value (replicate it for every component).
        // Expand it to word size.
        DB      $0F, $6F, $F0          /// MOVQ MM6, MM0
        DB      $0F, $69, $F6          /// PUNPCKHWD MM6, MM6
        DB      $0F, $6A, $F6          /// PUNPCKHDQ MM6, MM6

        // calculation is: target = (alpha * (source - target) + 256 * target) / 256
        DB      $0F, $F9, $C1          /// PSUBW     MM0, MM1,   source - target
        DB      $0F, $D5, $C6          /// PMULLW    MM0, MM6,   alpha * (source - target)
        DB      $0F, $FD, $C2          /// PADDW     MM0, MM2,   add target (in shifted form)
        DB      $0F, $71, $D0, $08     /// PSRLW     MM0, 8,     divide by 256

        // Bias is accounted for by conversion of range 0..255 to -128..127,
        // doing a saturated add and convert back to 0..255.
        DB      $0F, $F9, $C4          /// PSUBW     MM0, MM4
        DB      $0F, $ED, $C5          /// PADDSW    MM0, MM5
        DB      $0F, $FD, $C4          /// PADDW     MM0, MM4
        DB      $0F, $67, $C0          /// PACKUSWB  MM0, MM0,   convert words to bytes with saturation
        DB      $0F, $7E, $07          /// MOVD      [EDI], MM0, store the result
@3:
        ADD     ESI, 4
        ADD     EDI, 4
        DEC     ECX
        JNZ     @1
        POP     EDI
        POP     ESI
end;

//----------------------------------------------------------------------------------------------------------------------

procedure AlphaBlendLineMaster(Source, Destination: Pointer; Count: Integer; ConstantAlpha, Bias: Integer);

// Blends a line of Count pixels from Source to Destination using the source pixel and a constant alpha value.
// The layout of a pixel must be BGRA.
// ConstantAlpha must be in the range 0..255.
// Bias is an additional value which gets added to every component and must be in the range -128..127
//
// EAX contains Source
// EDX contains Destination
// ECX contains Count
// ConstantAlpha and Bias are on the stack

asm
        PUSH    ESI                    // save used registers
        PUSH    EDI

        MOV     ESI, EAX               // ESI becomes the actual source pointer
        MOV     EDI, EDX               // EDI becomes the actual target pointer

        // Load MM6 with the constant alpha value (replicate it for every component).
        // Expand it to word size.
        MOV     EAX, [ConstantAlpha]
        DB      $0F, $6E, $F0          /// MOVD      MM6, EAX
        DB      $0F, $61, $F6          /// PUNPCKLWD MM6, MM6
        DB      $0F, $62, $F6          /// PUNPCKLDQ MM6, MM6

        // Load MM5 with the bias value.
        MOV     EAX, [Bias]
        DB      $0F, $6E, $E8          /// MOVD      MM5, EAX
        DB      $0F, $61, $ED          /// PUNPCKLWD MM5, MM5
        DB      $0F, $62, $ED          /// PUNPCKLDQ MM5, MM5

        // Load MM4 with 128 to allow for saturated biasing.
        MOV     EAX, 128
        DB      $0F, $6E, $E0          /// MOVD      MM4, EAX
        DB      $0F, $61, $E4          /// PUNPCKLWD MM4, MM4
        DB      $0F, $62, $E4          /// PUNPCKLDQ MM4, MM4

@1:     // The pixel loop calculates an entire pixel in one run.
        // Note: The pixel byte values are expanded into the higher bytes of a word due
        //       to the way unpacking works. We compensate for this with an extra shift.
        DB      $0F, $EF, $C0          /// PXOR      MM0, MM0,   clear source pixel register for unpacking
        DB      $0F, $60, $06          /// PUNPCKLBW MM0, [ESI], unpack source pixel byte values into words
        DB      $0F, $71, $D0, $08     /// PSRLW     MM0, 8,     move higher bytes to lower bytes
        DB      $0F, $EF, $C9          /// PXOR      MM1, MM1,   clear target pixel register for unpacking
        DB      $0F, $60, $0F          /// PUNPCKLBW MM1, [EDI], unpack target pixel byte values into words
        DB      $0F, $6F, $D1          /// MOVQ      MM2, MM1,   make a copy of the shifted values, we need them again
        DB      $0F, $71, $D1, $08     /// PSRLW     MM1, 8,     move higher bytes to lower bytes

        // Load MM7 with the source alpha value (replicate it for every component).
        // Expand it to word size.
        DB      $0F, $6F, $F8          /// MOVQ      MM7, MM0
        DB      $0F, $69, $FF          /// PUNPCKHWD MM7, MM7
        DB      $0F, $6A, $FF          /// PUNPCKHDQ MM7, MM7
        DB      $0F, $D5, $FE          /// PMULLW    MM7, MM6,   source alpha * master alpha
        DB      $0F, $71, $D7, $08     /// PSRLW     MM7, 8,     divide by 256

        // calculation is: target = (alpha * master alpha * (source - target) + 256 * target) / 256
        DB      $0F, $F9, $C1          /// PSUBW     MM0, MM1,   source - target
        DB      $0F, $D5, $C7          /// PMULLW    MM0, MM7,   alpha * (source - target)
        DB      $0F, $FD, $C2          /// PADDW     MM0, MM2,   add target (in shifted form)
        DB      $0F, $71, $D0, $08     /// PSRLW     MM0, 8,     divide by 256

        // Bias is accounted for by conversion of range 0..255 to -128..127,
        // doing a saturated add and convert back to 0..255.
        DB      $0F, $F9, $C4          /// PSUBW     MM0, MM4
        DB      $0F, $ED, $C5          /// PADDSW    MM0, MM5
        DB      $0F, $FD, $C4          /// PADDW     MM0, MM4
        DB      $0F, $67, $C0          /// PACKUSWB  MM0, MM0,   convert words to bytes with saturation
        DB      $0F, $7E, $07          /// MOVD      [EDI], MM0, store the result
@3:
        ADD     ESI, 4
        ADD     EDI, 4
        DEC     ECX
        JNZ     @1
        POP     EDI
        POP     ESI
end;

//----------------------------------------------------------------------------------------------------------------------

procedure AlphaBlendLineMasterAndColor(Destination: Pointer; Count: Integer; ConstantAlpha, Color: Integer);

// Blends a line of Count pixels in Destination against the given color using a constant alpha value.
// The layout of a pixel must be BGRA and Color must be rrggbb00 (as stored by a COLORREF).
// ConstantAlpha must be in the range 0..255.
//
// EAX contains Destination
// EDX contains Count
// ECX contains ConstantAlpha
// Color is passed on the stack

asm
        // The used formula is: target = (alpha * color + (256 - alpha) * target) / 256.
        // alpha * color (factor 1) and 256 - alpha (factor 2) are constant values which can be calculated in advance.
        // The remaining calculation is therefore: target = (F1 + F2 * target) / 256

        // Load MM3 with the constant alpha value (replicate it for every component).
        // Expand it to word size. (Every calculation here works on word sized operands.)
        DB      $0F, $6E, $D9          /// MOVD      MM3, ECX
        DB      $0F, $61, $DB          /// PUNPCKLWD MM3, MM3
        DB      $0F, $62, $DB          /// PUNPCKLDQ MM3, MM3

        // Calculate factor 2.
        MOV     ECX, $100
        DB      $0F, $6E, $D1          /// MOVD      MM2, ECX
        DB      $0F, $61, $D2          /// PUNPCKLWD MM2, MM2
        DB      $0F, $62, $D2          /// PUNPCKLDQ MM2, MM2
        DB      $0F, $F9, $D3          /// PSUBW     MM2, MM3             // MM2 contains now: 255 - color = F2

        // Now calculate factor 1. Alpha is still in MM3, but the r and b components of Color must be swapped.
        MOV     ECX, [Color]
        BSWAP   ECX
        ROR     ECX, 8
        DB      $0F, $6E, $C9          /// MOVD      MM1, ECX             // Load the color and convert to word sized values.
        DB      $0F, $EF, $E4          /// PXOR      MM4, MM4
        DB      $0F, $60, $CC          /// PUNPCKLBW MM1, MM4
        DB      $0F, $D5, $CB          /// PMULLW    MM1, MM3             // MM1 contains now: color * alpha = F1

@1:     // The pixel loop calculates an entire pixel in one run.
        DB      $0F, $6E, $00          /// MOVD      MM0, [EAX]
        DB      $0F, $60, $C4          /// PUNPCKLBW MM0, MM4

        DB      $0F, $D5, $C2          /// PMULLW    MM0, MM2             // calculate F1 + F2 * target
        DB      $0F, $FD, $C1          /// PADDW     MM0, MM1
        DB      $0F, $71, $D0, $08     /// PSRLW     MM0, 8               // divide by 256

        DB      $0F, $67, $C0          /// PACKUSWB  MM0, MM0             // convert words to bytes with saturation
        DB      $0F, $7E, $00          /// MOVD      [EAX], MM0           // store the result

        ADD     EAX, 4
        DEC     EDX
        JNZ     @1
end;

//----------------------------------------------------------------------------------------------------------------------

procedure EMMS;

// Reset MMX state to use the FPU for other tasks again.

asm
        DB      $0F, $77               /// EMMS
end;

//----------------------------------------------------------------------------------------------------------------------

function GetBitmapBitsFromDeviceContext(DC: HDC; var Width, Height: Integer): Pointer;

// Helper function used to retrieve the bitmap selected into the given device context. If there is a bitmap then
// the function will return a pointer to its bits otherwise nil is returned.
// Additionally the dimensions of the bitmap are returned. 

var
  Bitmap: HBITMAP;
  DIB: TDIBSection;

begin
  Result := nil;
  Width := 0;
  Height := 0;

  Bitmap := GetCurrentObject(DC, OBJ_BITMAP);
  if Bitmap <> 0 then
  begin
    if GetObject(Bitmap, SizeOf(DIB), @DIB) = SizeOf(DIB) then
    begin
      Result := DIB.dsBm.bmBits;
      Width := DIB.dsBmih.biWidth;
      Height := DIB.dsBmih.biHeight;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function CalculateScanline(Bits: Pointer; Width, Height, Row: Integer): Pointer;

// Helper function to calculate the start address for the given row.

begin
  if Height > 0 then  // bottom-up DIB
    Row := Height - Row - 1;
  // Return DWORD aligned address of the requested scanline.
  Integer(Result) := Integer(Bits) + Row * ((Width * 32 + 31) and not 31) div 8;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure AlphaBlend(Source, Destination: HDC; R: TRect; Target: TPoint; Mode: TBlendMode; ConstantAlpha, Bias: Integer);

// Optimized alpha blend procedure using MMX instructions to perform as quick as possible.
// For this procedure to work properly it is important that both source and target bitmap use the 32 bit color format.
// R describes the source rectangle to work on.
// Target is the place (upper left corner) in the target bitmap where to blend to. Note that source width + X offset
// must be less or equal to the target width. Similar for the height.
// If Mode is bmConstantAlpha then the blend operation uses the given ConstantAlpha value for all pixels.
// If Mode is bmPerPixelAlpha then each pixel is blended using its individual alpha value (the alpha value of the source).
// If Mode is bmMasterAlpha then each pixel is blended using its individual alpha value multiplied by ConstantAlpha.
// If Mode is bmConstantAlphaAndColor then each destination pixel is blended using ConstantAlpha but also a constant
// color which will be obtained from Bias. In this case no offset value is added, otherwise Bias is used as offset.
// Blending of a color into target only (bmConstantAlphaAndColor) ignores Source (the DC) and Target (the position).
// CAUTION: This procedure does not check whether MMX instructions are actually available! Call it only if MMX is really
//          usable.

var
  Y: Integer;
  SourceRun,
  TargetRun: PByte;

  SourceBits,
  DestBits: Pointer;
  SourceWidth,
  SourceHeight,
  DestWidth,
  DestHeight: Integer;
  
begin                              
  if not IsRectEmpty(R) then
  begin
    // Note: it is tempting to optimize the special cases for constant alpha 0 and 255 by just ignoring soure
    //       (alpha = 0) or simply do a blit (alpha = 255). But this does not take the bias into account.
    case Mode of
      bmConstantAlpha:
        begin
          // Get a pointer to the bitmap bits for the source and target device contexts.
          // Note: this supposes that both contexts do actually have bitmaps assigned!
          SourceBits := GetBitmapBitsFromDeviceContext(Source, SourceWidth, SourceHeight);
          DestBits := GetBitmapBitsFromDeviceContext(Destination, DestWidth, DestHeight);
          if Assigned(SourceBits) and Assigned(DestBits) then
          begin
            for Y := 0 to R.Bottom - R.Top - 1 do
            begin
              SourceRun := CalculateScanline(SourceBits, SourceWidth, SourceHeight, Y + R.Top);
              Inc(SourceRun, 4 * R.Left);
              TargetRun := CalculateScanline(DestBits, DestWidth, DestHeight, Y + Target.Y);
              Inc(TargetRun, 4 * Target.X);
              AlphaBlendLineConstant(SourceRun, TargetRun, R.Right - R.Left, ConstantAlpha, Bias);
            end;
          end;
          EMMS;
        end;
      bmPerPixelAlpha:
        begin
          SourceBits := GetBitmapBitsFromDeviceContext(Source, SourceWidth, SourceHeight);
          DestBits := GetBitmapBitsFromDeviceContext(Destination, DestWidth, DestHeight);
          if Assigned(SourceBits) and Assigned(DestBits) then
          begin
            for Y := 0 to R.Bottom - R.Top - 1 do
            begin
              SourceRun := CalculateScanline(SourceBits, SourceWidth, SourceHeight, Y + R.Top);
              Inc(SourceRun, 4 * R.Left);
              TargetRun := CalculateScanline(DestBits, DestWidth, DestHeight, Y + Target.Y);
              Inc(TargetRun, 4 * Target.X);
              AlphaBlendLinePerPixel(SourceRun, TargetRun, R.Right - R.Left, Bias);
            end;
          end;
          EMMS;
        end;
      bmMasterAlpha:
        begin
          SourceBits := GetBitmapBitsFromDeviceContext(Source, SourceWidth, SourceHeight);
          DestBits := GetBitmapBitsFromDeviceContext(Destination, DestWidth, DestHeight);
          if Assigned(SourceBits) and Assigned(DestBits) then
          begin
            for Y := 0 to R.Bottom - R.Top - 1 do
            begin
              SourceRun := CalculateScanline(SourceBits, SourceWidth, SourceHeight, Y + R.Top);
              Inc(SourceRun, 4 * Target.X);
              TargetRun := CalculateScanline(DestBits, DestWidth, DestHeight, Y + Target.Y);
              AlphaBlendLineMaster(SourceRun, TargetRun, R.Right - R.Left, ConstantAlpha, Bias);
            end;
          end;
          EMMS;
        end;
      bmConstantAlphaAndColor:
        begin
          // Source is ignore since there is a constant color value.
          DestBits := GetBitmapBitsFromDeviceContext(Destination, DestWidth, DestHeight);
          if Assigned(DestBits) then
          begin
            for Y := 0 to R.Bottom - R.Top - 1 do
            begin
              TargetRun := CalculateScanline(DestBits, DestWidth, DestHeight, Y + R.Top);
              Inc(TargetRun, 4 * R.Left);
              AlphaBlendLineMasterAndColor(TargetRun, R.Right - R.Left, ConstantAlpha, Bias);
            end;
          end;
          EMMS;
        end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function GetRGBColor(Value: TColor): DWORD;

// Little helper to convert a Delphi color to an image list color.

begin
  Result := ColorToRGB(Value);
  case Result of
    clNone:
      Result := CLR_NONE;
    clDefault:
      Result := CLR_DEFAULT;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

const
  Grays: array[0..3] of TColor = (clWhite, clSilver, clGray, clBlack);
  SysGrays: array[0..3] of TColor = (clWindow, clBtnFace, clBtnShadow, clBtnText);

procedure ConvertImageList(IL: TImageList; const ImageName: string; ColorRemapping: Boolean = True);

// Loads a bunch of images given by ImageName into IL. If ColorRemapping = True then a mapping of gray values to
// system colors is performed.

var
  Images,
  OneImage: TBitmap;
  I: Integer;
  MaskColor: TColor;
  Source,
  Dest: TRect;

begin
  Watcher.Enter;
  try
    // Since we want the image list appearing in the correct system colors, we have to remap its colors.
    Images := TBitmap.Create;
    OneImage := TBitmap.Create;
    if ColorRemapping then
      Images.Handle := CreateMappedRes(FindClassHInstance(TBaseVirtualTree), PChar(ImageName), Grays, SysGrays)
    else
      Images.Handle := LoadBitmap(FindClassHInstance(TBaseVirtualTree), PChar(ImageName));

    try                
      Assert(Images.Height > 0, 'Internal image "' + ImageName + '" is missing or corrupt.');

      // It is assumed that the image height determines also the width of one entry in the image list.
      IL.Clear;
      IL.Height := Images.Height;
      IL.Width := Images.Height;
      OneImage.Width := IL.Width;
      OneImage.Height := IL.Height;
      MaskColor := Images.Canvas.Pixels[0, 0]; // this is usually clFuchsia
      Dest := Rect(0, 0, IL.Width, IL.Height);
      for I := 0 to (Images.Width div Images.Height) - 1 do
      begin
        Source := Rect(I * IL.Width, 0, (I + 1) * IL.Width, IL.Height);
        OneImage.Canvas.CopyRect(Dest, Images.Canvas, Source);
        IL.AddMasked(OneImage, MaskColor);
      end;
    finally
      Images.Free;
      OneImage.Free;
    end;
  finally
    Watcher.Leave;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function HasMMX: Boolean;

// Helper method to determine whether the current processor supports MMX.

asm
        PUSH    EBX
        XOR     EAX, EAX     // Result := False
        PUSHFD               // determine if the processor supports the CPUID command
        POP     EDX
        MOV     ECX, EDX
        XOR     EDX, $200000
        PUSH    EDX
        POPFD
        PUSHFD
        POP     EDX
        XOR     ECX, EDX
        JZ      @1           // no CPUID support so we can't even get to the feature information 
        PUSH    EDX
        POPFD

        MOV     EAX, 1
        DW      $A20F        // CPUID, EAX contains now version info and EDX feature information
        MOV     EBX, EAX     // free EAX to get the result value
        XOR     EAX, EAX     // Result := False
        CMP     EBX, $50
        JB      @1           // if processor family is < 5 then it is not a Pentium class processor
        TEST    EDX, $800000
        JZ      @1           // if the MMX bit is not set then we don't have MMX
        INC     EAX          // Result := True
@1:
        POP     EBX
end;
 
//----------------------------------------------------------------------------------------------------------------------

procedure InitializeGlobalStructures;

// initialization of stuff global to the unit

var
  {$ifndef COMPILER_5_UP}
    NonClientMetrics: TNonClientMetrics;
  {$endif COMPILER_5_UP}
  Flags: Cardinal;
  
begin
  // This watcher is used whenever a global structure could be modified by more than one thread.
  Watcher := TCriticalSection.Create;

  // For the drag image a fast MMX blend routine is used. We have to make sure MMX is available.
  MMXAvailable := HasMMX;

  // There is a bug in Win95 and WinME (and potentially in Win98 too) regarding GetDCEx which causes sometimes
  // serious trouble within GDI (see method WMNCPaint).
  IsWinNT := (Win32Platform and VER_PLATFORM_WIN32_NT) <> 0;
  IsWin2K := IsWinNT and (Win32MajorVersion > 4);
  isWinXP := IsWin2K and (Win32MinorVersion > 0);

  // Initialize OLE subsystem for drag'n drop and clipboard operations.
  if not Succeeded(OleInitialize(nil)) then
    RaiseLastOSError;

  // Register the tree reference clipboard format. Others will be handled in InternalClipboarFormats.
  CF_VTREFERENCE := RegisterClipboardFormat(CFSTR_VTREFERENCE);

  // Load all internal image lists and convert their colors to current desktop color scheme.
  // In order to use high color images we have to create the image list handle ourselves.
  if IsWinNT then
    Flags := ILC_COLOR32 or ILC_MASK
  else
    Flags := ILC_COLOR16 or ILC_MASK;
  LightCheckImages := TImageList.Create(nil);
  with LightCheckImages do
    Handle := ImageList_Create(16, 16, Flags, 0, AllocBy);
  ConvertImageList(LightCheckImages, 'VT_CHECK_LIGHT');

  DarkCheckImages := TImageList.CreateSize(16, 16);
  with DarkCheckImages do
    Handle := ImageList_Create(16, 16, Flags, 0, AllocBy);
  ConvertImageList(DarkCheckImages, 'VT_CHECK_DARK');

  LightTickImages := TImageList.CreateSize(16, 16);
  with LightTickImages do
    Handle := ImageList_Create(16, 16, Flags, 0, AllocBy);
  ConvertImageList(LightTickImages, 'VT_TICK_LIGHT');

  DarkTickImages := TImageList.CreateSize(16, 16);
  with DarkTickImages do
    Handle := ImageList_Create(16, 16, Flags, 0, AllocBy);
  ConvertImageList(DarkTickImages, 'VT_TICK_DARK');

  FlatImages := TImageList.CreateSize(16, 16);
  with FlatImages do
    Handle := ImageList_Create(16, 16, Flags, 0, AllocBy);
  ConvertImageList(FlatImages, 'VT_FLAT');

  XPImages := TImageList.CreateSize(16, 16);
  with XPImages do
    Handle := ImageList_Create(16, 16, Flags, 0, AllocBy);
  ConvertImageList(XPImages, 'VT_XP', False);

  UtilityImages := TImageList.CreateSize(16, 16);
  with UtilityImages do
    Handle := ImageList_Create(16, 16, Flags, 0, AllocBy);
  ConvertImageList(UtilityImages, 'VT_UTILITIES');

  {$ifndef COMPILER_5_UP}
    // In Delphi 4 there is no TScreen.HintFont hence we have to manage this manually.
    HintFont := TFont.Create;
    NonClientMetrics.cbSize := SizeOf(NonClientMetrics);
    if SystemParametersInfo(SPI_GETNONCLIENTMETRICS, 0, @NonClientMetrics, 0) then
      HintFont.Handle := CreateFontIndirect(NonClientMetrics.lfStatusFont)
    else
      HintFont.Size := 8;
  {$endif COMPILER_5_UP}

  // Specify an useful timer resolution for timeGetTime.
  timeBeginPeriod(MinimumTimerInterval);
  InternalClipboardFormats := TClipboardFormatList.Create;

  // Initialize themes support if we are running on Windows XP and up.
  if IsWin2K and (Win32MinorVersion > 0) then
    InitThemeLibrary;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure FinalizeGlobalStructures;

begin
  InternalClipboardFormats.Free;
  timeEndPeriod(MinimumTimerInterval);                        
  {$ifndef COMPILER_5_UP}
    HintFont.Free;
  {$endif COMPILER_5_UP}

  LightCheckImages.Free;
  DarkCheckImages.Free;
  LightTickImages.Free;
  DarkTickImages.Free;
  FlatImages.Free;
  XPImages.Free;
  UtilityImages.Free;

  OleUninitialize;
  Watcher.Free;

  FreeThemeLibrary;
end;

//----------------- TWorkerThread --------------------------------------------------------------------------------------

procedure AddThreadReference;

begin
  if WorkerThread = nil then
  begin
    // Create an event used to trigger our worker thread when something is to do.
    WorkEvent := CreateEvent(nil, False, False, nil);
    if WorkEvent = 0 then
      RaiseLastOSError;

    // Create worker thread, initialize it and send it to its wait loop.
    WorkerThread := TWorkerThread.Create(False);
  end;
  Inc(WorkerThread.FRefCount);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure ReleaseThreadReference(Tree: TBaseVirtualTree);

begin
  if Assigned(WorkerThread) then
  begin
    Dec(WorkerThread.FRefCount);

    // Make sure there is no reference remaining to the releasing tree.
    Tree.InterruptValidation;

    if WorkerThread.FRefCount = 0 then
    begin
      with WorkerThread do
      begin
        Terminate;
        SetEvent(WorkEvent);

        // The following work around is no longer necessary with Delphi 6 and up.
        {$ifndef COMPILER_6_UP}
          // There is a problem when the thread is freed in the exit code of a DLL. This can happen when a tree is
          // destroyed on unload of a DLL (e.g. control panel applet). In this case only the main thread will get
          // CPU time, other threads will never awake again. The VCL however waits for a thread when freeing it
          // which will result in a deadlock (the WaitFor call does not return because the thread does not get CPU time).
          // If a thread is however suspended then the VCL does not wait and all is fine.
          if IsLibrary then
            Suspend;
        {$endif COMPILER_6_UP}

        WorkerThread.Free;
      end;
      WorkerThread := nil;
      CloseHandle(WorkEvent);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

constructor TWorkerThread.Create(CreateSuspended: Boolean);

begin
  inherited Create(CreateSuspended);
  FWaiterList := TThreadList.Create;
end;

//----------------------------------------------------------------------------------------------------------------------

destructor TWorkerThread.Destroy;

begin
  FWaiterList.Free;
  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TWorkerThread.Execute;

// Does some background tasks, like validating tree caches.

begin
  while not Terminated do
  begin
    WaitForSingleObject(WorkEvent, INFINITE);
    if not Terminated then 
    begin
      // Get the next waiting tree.
      with FWaiterList.LockList do
      try
        if Count > 0 then
        begin
          FCurrentTree := Items[0];
          // Remove this tree from waiter list.
          Delete(0);
        end
        else
          FCurrentTree := nil;
      finally
        FWaiterList.UnlockList;
      end;

      // Something to do?
      if Assigned(FCurrentTree) then
      try
        FCurrentTree.DoValidateCache;
      finally
        FCurrentTree := nil;
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TWorkerThread.AddTree(Tree: TBaseVirtualTree);

begin
  Assert(Assigned(Tree), 'Tree must not be nil.');
  
  with FWaiterList.LockList do
  try
    if IndexOf(Tree) = -1 then
      Add(Tree);
  finally
    FWaiterList.UnlockList;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TWorkerThread.RemoveTree(Tree: TBaseVirtualTree);

begin
  Assert(Assigned(Tree), 'Tree must not be nil.');

  with FWaiterList.LockList do
  try
    Remove(Tree);
  finally
    FWaiterList.UnlockList;
  end;
end;

//----------------- TBufferedString ------------------------------------------------------------------------------------

const
  AllocIncrement = 4096;
  
destructor TBufferedString.Destroy;

begin
  FreeMem(FStart);
  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBufferedString.GetAsString: string;

begin
  SetString(Result, FStart, FPosition - FStart);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBufferedString.Add(const S: string);

var
  LastLen,
  LastOffset,
  Len: Integer;

begin
  Len := Length(S);
  // Make room for the new string.
  if FEnd - FPosition <= Len then
  begin
    // Keep last offset to restore it correctly in the case that FStart gets a new memory block assigned.
    LastLen := FEnd - FStart;
    LastOffset := FPosition - FStart;
    ReallocMem(FStart, FEnd - FStart + AllocIncrement);
    FPosition := FStart + LastOffset;
    FEnd := FStart + LastLen + AllocIncrement;
  end;                     
  Move(PChar(S)^, FPosition^, Len);
  Inc(FPosition, Len);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBufferedString.AddNewLine;

var
  LastLen,
  LastOffset: Integer;

begin
  // Make room for the CR/LF characters.
  if FEnd - FPosition <= 2 then
  begin
    // Keep last offset to restore it correctly in the case that FStart gets a new memory block assigned.
    LastLen := FEnd - FStart;
    LastOffset := FPosition - FStart;
    ReallocMem(FStart, FEnd - FStart + AllocIncrement);
    FPosition := FStart + LastOffset;
    FEnd := FStart + LastLen + AllocIncrement;
  end;
  FPosition^ := #13;
  Inc(FPosition);
  FPosition^ := #10;
  Inc(FPosition);
end;

//----------------- TWideBufferedString --------------------------------------------------------------------------------

destructor TWideBufferedString.Destroy;

begin
  FreeMem(FStart);
  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

function TWideBufferedString.GetAsString: WideString;

begin
  SetString(Result, FStart, FPosition - FStart);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TWideBufferedString.Add(const S: WideString);

var
  LastLen,
  LastOffset,
  Len: Integer;

begin
  Len := Length(S);
  // Make room for the new string.
  if FEnd - FPosition <= Len then
  begin
    // Keep last offset to restore it correctly in the case that FStart gets a new memory block assigned.
    LastLen := FEnd - FStart;
    LastOffset := FPosition - FStart;
    ReallocMem(FStart, 2 * (FEnd - FStart + AllocIncrement));
    FPosition := FStart + LastOffset;
    FEnd := FStart + LastLen + AllocIncrement;
  end;                     
  Move(PWideChar(S)^, FPosition^, 2 * Len);
  Inc(FPosition, Len);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TWideBufferedString.AddNewLine;

var
  LastLen,
  LastOffset: Integer;

begin
  // Make room for the CR/LF characters.
  if FEnd - FPosition <= 4 then
  begin
    // Keep last offset to restore it correctly in the case that FStart gets a new memory block assigned.
    LastLen := FEnd - FStart;
    LastOffset := FPosition - FStart;
    ReallocMem(FStart, 2 * (FEnd - FStart + AllocIncrement));
    FPosition := FStart + LastOffset;
    FEnd := FStart + LastLen + AllocIncrement;
  end;
  FPosition^ := #13;
  Inc(FPosition);
  FPosition^ := #10;
  Inc(FPosition);
end;

//----------------- TCustomVirtualTreeOptions --------------------------------------------------------------------------

constructor TCustomVirtualTreeOptions.Create(AOwner: TBaseVirtualTree);

begin
  FOwner := AOwner;

  FPaintOptions := DefaultPaintOptions;
  FAnimationOptions := DefaultAnimationOptions;
  FAutoOptions := DefaultAutoOptions;
  FSelectionOptions := DefaultSelectionOptions;
  FMiscOptions := DefaultMiscOptions;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeOptions.SetAnimationOptions(const Value: TVTAnimationOptions);

begin
  FAnimationOptions := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeOptions.SetAutoOptions(const Value: TVTAutoOptions);

var
  ChangedOptions: TVTAutoOptions;

begin
  if FAutoOptions <> Value then
  begin
    // Exclusive ORing to get all entries wich are in either set but not in both.
    ChangedOptions := FAutoOptions + Value - (FAutoOptions * Value);
    FAutoOptions := Value;
    with FOwner do
      if (toAutoSpanColumns in ChangedOptions) and not (csLoading in ComponentState) and HandleAllocated then
        Invalidate;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeOptions.SetMiscOptions(const Value: TVTMiscOptions);

var
  ToBeSet,
  ToBeCleared: TVTMiscOptions;

begin
  if FMiscOptions <> Value then
  begin
    ToBeSet := Value - FMiscOptions;
    ToBeCleared := FMiscOptions - Value;
    FMiscOptions := Value;

    with FOwner do
      if not (csLoading in ComponentState) and HandleAllocated then
      begin
        if toCheckSupport in ToBeSet + ToBeCleared then
          Invalidate;
        if not (csDesigning in ComponentState) then
        begin
          if toFullRepaintOnResize in TobeSet + ToBeCleared then
            RecreateWnd;
          if toAcceptOLEDrop in ToBeSet then
            RegisterDragDrop(Handle, DragManager as IDropTarget);
          if toAcceptOLEDrop in ToBeCleared then
            RevokeDragDrop(Handle);
        end;
      end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeOptions.SetPaintOptions(const Value: TVTPaintOptions);

var
  ToBeSet,
  ToBeCleared: TVTPaintOptions;

begin
  if FPaintOptions <> Value then
  begin
    ToBeSet := Value - FPaintOptions;
    ToBeCleared := FPaintOptions - Value;
    FPaintOptions := Value;
    with FOwner do
      if not (csLoading in ComponentState) and HandleAllocated then
      begin
        if toThemeAware in ToBeSet + ToBeCleared then
          Perform(WM_THEMECHANGED, 0, 0)  // includes redrawing the window
        else
          Invalidate;
      end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeOptions.SetSelectionOptions(const Value: TVTSelectionOptions);

var
  ToBeSet,
  ToBeCleared: TVTSelectionOptions;

begin
  if FSelectionOptions <> Value then
  begin
    ToBeSet := Value - FSelectionOptions;
    ToBeCleared := FSelectionOptions - Value;
    FSelectionOptions := Value;

    with FOwner do
    begin
      if (toMultiSelect in (ToBeCleared + ToBeSet)) or
        ([toLevelSelectConstraint, toSiblingSelectConstraint] * ToBeSet <> []) then
        ClearSelection;

      if (toExtendedFocus in ToBeCleared) and (FFocusedColumn > 0) and HandleAllocated then
      begin
        FFocusedColumn := FHeader.MainColumn;
        Invalidate;
      end;

      if not (toExtendedFocus in FSelectionOptions) then
        FFocusedColumn := FHeader.MainColumn;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeOptions.AssignTo(Dest: TPersistent);

begin
  if Dest is TCustomVirtualTreeOptions then
  begin
    with Dest as TCustomVirtualTreeOptions do
    begin
      PaintOptions := Self.PaintOptions;
      AnimationOptions := Self.AnimationOptions;
      AutoOptions := Self.AutoOptions;
      SelectionOptions := Self.SelectionOptions;
      MiscOptions := Self.MiscOptions;
    end;
  end
  else
    inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

// OLE drag and drop support classes
// This is quite heavy stuff (compared with the VCL implementation) but is much better suited to fit the needs
// of DD'ing various kinds of virtual data and works also between applications.

//----------------- TEnumFormatEtc -------------------------------------------------------------------------------------

constructor TEnumFormatEtc.Create(Tree: TBaseVirtualTree; AFormatEtcArray: TFormatEtcArray);

var
  I: Integer;

begin
  inherited Create;

  FTree := Tree;
  // Make a local copy of the format data.
  SetLength(FFormatEtcArray, Length(AFormatEtcArray));
  for I := 0 to High(AFormatEtcArray) do
    FFormatEtcArray[I] := AFormatEtcArray[I];
end;

//----------------------------------------------------------------------------------------------------------------------

function TEnumFormatEtc.Clone(out Enum: IEnumFormatEtc): HResult;

var
  AClone: TEnumFormatEtc;

begin
  Result := S_OK;
  try
    AClone := TEnumFormatEtc.Create(nil, FFormatEtcArray);
    AClone.FCurrentIndex := FCurrentIndex;
    Enum := AClone as IEnumFormatEtc;
  except
    Result := E_FAIL;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TEnumFormatEtc.Next(celt: Integer; out elt; pceltFetched: PLongint): HResult;

var
  CopyCount: Integer;

begin
  Result := S_FALSE;
  CopyCount := Length(FFormatEtcArray) - FCurrentIndex;
  if celt < CopyCount then
    CopyCount := celt;
  if CopyCount > 0 then
  begin
    Move(FFormatEtcArray[FCurrentIndex], elt, CopyCount * SizeOf(TFormatEtc));
    Inc(FCurrentIndex, CopyCount);
    Result := S_OK;
  end;
  if Assigned(pceltFetched) then
    pceltFetched^ := CopyCount;
end;

//----------------------------------------------------------------------------------------------------------------------

function TEnumFormatEtc.Reset: HResult;

begin
  FCurrentIndex := 0;
  Result := S_OK;
end;

//----------------------------------------------------------------------------------------------------------------------

function TEnumFormatEtc.Skip(celt: Integer): HResult;

begin
  if FCurrentIndex + celt < High(FFormatEtcArray) then
  begin
    Inc(FCurrentIndex, celt);
    Result := S_Ok;
  end
  else
    Result := S_FALSE;
end;

//----------------- TVTDataObject --------------------------------------------------------------------------------------

constructor TVTDataObject.Create(AOwner: TBaseVirtualTree; ForClipboard: Boolean);

begin
  inherited Create;

  FOwner := AOwner;
  FForClipboard := ForClipboard;
  FOwner.GetNativeClipboardFormats(FFormatEtcArray);
end;

//----------------------------------------------------------------------------------------------------------------------

destructor TVTDataObject.Destroy;

var
  I: Integer;
  StgMedium: PStgMedium;
  
begin
  // Cancel a pending clipboard operation if this data object was created for the clipboard and
  // is freed because something else is placed there.
  if FForClipboard and not (tsClipboardFlushing in FOwner.FStates) then
    FOwner.CancelCutOrCopy;

  // Release any internal clipboard formats
  for I := 0 to High(FormatEtcArray) do
  begin
    StgMedium := FindInternalStgMedium(FormatEtcArray[I].cfFormat);
    if Assigned(StgMedium) then
      ReleaseStgMedium(StgMedium^);
  end;

  FormatEtcArray := nil;
  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTDataObject.CanonicalIUnknown(TestUnknown: IUnknown): IUnknown;

// Uses COM object identity: An explicit call to the IUnknown::QueryInterface method, requesting the IUnknown
// interface, will always return the same pointer.

begin
  if Assigned(TestUnknown) then
  begin
    if TestUnknown.QueryInterface(IUnknown, Result) = 0 then
      Result._Release // Don't actually need it just need the pointer value
    else
      Result := TestUnknown
  end
  else
    Result := TestUnknown
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTDataObject.EqualFormatEtc(FormatEtc1, FormatEtc2: TFormatEtc): Boolean;

begin
  Result := (FormatEtc1.cfFormat = FormatEtc2.cfFormat) and (FormatEtc1.ptd = FormatEtc2.ptd) and
    (FormatEtc1.dwAspect = FormatEtc2.dwAspect) and (FormatEtc1.lindex = FormatEtc2.lindex) and
    (FormatEtc1.tymed and FormatEtc2.tymed <> 0);
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTDataObject.FindFormatEtc(TestFormatEtc: TFormatEtc; const FormatEtcArray: TFormatEtcArray): integer;

var
  I: integer;

begin
  Result := -1;
  for I := 0 to High(FormatEtcArray) do
  begin
    if EqualFormatEtc(TestFormatEtc, FormatEtcArray[I]) then
    begin
      Result := I;
      Break;
    end
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTDataObject.FindInternalStgMedium(Format: TClipFormat): PStgMedium;

var
  I: integer;
begin
  Result := nil;
  for I := 0 to High(InternalStgMediumArray) do
  begin
    if Format = InternalStgMediumArray[I].Format then
    begin
      Result := @InternalStgMediumArray[I].Medium;
      Break;
    end
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTDataObject.HGlobalClone(HGlobal: THandle): THandle;

// Returns a global memory block that is a copy of the passed memory block.

var
  Size: Cardinal;
  Data,
  NewData: PChar;

begin
  Size := GlobalSize(HGlobal);
  Result := GlobalAlloc(GPTR, Size);
  Data := GlobalLock(hGlobal);
  try
    NewData := GlobalLock(Result);
    try
      Move(Data^, NewData^, Size);
    finally
      GlobalUnLock(Result);
    end
  finally
    GlobalUnLock(hGlobal);
  end
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTDataObject.RenderInternalOLEData(const FormatEtcIn: TFormatEtc; var Medium: TStgMedium;
  var OLEResult: HResult): Boolean;

// Tries to render one of the formats which have been stored via the SetData method.
// Since this data is already there it is just copied or its reference count is increased (depending on storage medium).

var
  InternalMedium: PStgMedium;

begin
  Result := True;
  InternalMedium := FindInternalStgMedium(FormatEtcIn.cfFormat);
  if Assigned(InternalMedium) then
    OLEResult := StgMediumIncRef(InternalMedium^, Medium, False, Self as IDataObject)
  else
    Result := False;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTDataObject.StgMediumIncRef(const InStgMedium: TStgMedium; var OutStgMedium: TStgMedium;
  CopyInMedium: Boolean; DataObject: IDataObject): HRESULT;

// InStgMedium is the data that is requested, OutStgMedium is the data that we are to return either a copy of or
// increase the IDataObject's reference and send ourselves back as the data (unkForRelease). The InStgMedium is usually
// the result of a call to find a particular FormatEtc that has been stored locally through a call to SetData.
// If CopyInMedium is not true we already have a local copy of the data when the SetData function was called (during
// that call the CopyInMedium must be true). Then as the caller asks for the data through GetData we do not have to make
// copy of the data for the caller only to have them destroy it then need us to copy it again if necessary.
// This way we increase the reference count to ourselves and pass the STGMEDIUM structure initially stored in SetData.
// This way when the caller frees the structure it sees the unkForRelease is not nil and calls Release on the object
// instead of destroying the actual data.                  

var
  Len: Integer;
  
begin
  Result := S_OK;

  // Simply copy all fields to start with.
  OutStgMedium := InStgMedium;
  // The data handled here always results from a call of SetData we got. This ensures only one storage format
  // is indicated and hence the case statement below is safe (IDataObject.GetData can optionally use several
  // storage formats).
  case InStgMedium.tymed of
    TYMED_HGLOBAL:
      begin
        if CopyInMedium then
        begin
          // Generate a unique copy of the data passed                   
          OutStgMedium.hGlobal := HGlobalClone(InStgMedium.hGlobal);
          if OutStgMedium.hGlobal = 0 then
            Result := E_OUTOFMEMORY
        end
        else
          // Don't generate a copy just use ourselves and the copy previously saved.
          OutStgMedium.unkForRelease := Pointer(DataObject); // Does not increase RefCount.
      end;
    TYMED_FILE:
      begin
        Len := lstrLenW(InStgMedium.lpszFileName) + 1; // Don'nt forget the terminating null character.
        OutStgMedium.lpszFileName := CoTaskMemAlloc(2 * Len);
        Move(InStgMedium.lpszFileName^, OutStgMedium.lpszFileName^, 2 * Len);
      end;
    TYMED_ISTREAM:
      IUnknown(OutStgMedium.stm)._AddRef;
    TYMED_ISTORAGE:
      IUnknown(OutStgMedium.stg)._AddRef;
    TYMED_GDI:                   
      if not CopyInMedium then
        // Don't generate a copy just use ourselves and the copy previously saved data.
        OutStgMedium.unkForRelease := Pointer(DataObject) // Does not increase RefCount.
      else
        Result := DV_E_TYMED; // Don't know how to copy GDI objects right now.
    TYMED_MFPICT:
      if not CopyInMedium then
        // Don't generate a copy just use ourselves and the copy previously saved data.
        OutStgMedium.unkForRelease := Pointer(DataObject) // Does not increase RefCount.
      else
        Result := DV_E_TYMED; // Don't know how to copy MetaFile objects right now.
    TYMED_ENHMF:
      if not CopyInMedium then
        // Don't generate a copy just use ourselves and the copy previously saved data.
        OutStgMedium.unkForRelease := Pointer(DataObject) // Does not increase RefCount.
      else
        Result := DV_E_TYMED; // Don't know how to copy enhanced metafiles objects right now.
  else
    Result := DV_E_TYMED;
  end;
  
  if (Result = S_OK) and Assigned(OutStgMedium.unkForRelease) then
    IUnknown(OutStgMedium.unkForRelease)._AddRef;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTDataObject.DAdvise(const FormatEtc: TFormatEtc; advf: Integer; const advSink: IAdviseSink;
  out dwConnection: Integer): HResult;

// Advise sink management is greatly simplified by the IDataAdviseHolder interface.
// We use this interface and forward all concerning calls to it.

begin
  Result := S_OK;
  if FAdviseHolder = nil then
    Result := CreateDataAdviseHolder(FAdviseHolder);
  if Result = S_OK then
    Result := FAdviseHolder.Advise(Self as IDataObject, FormatEtc, advf, advSink, dwConnection);
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTDataObject.DUnadvise(dwConnection: Integer): HResult;

begin
  if FAdviseHolder = nil then
    Result := E_NOTIMPL
  else
    Result := FAdviseHolder.Unadvise(dwConnection);
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTDataObject.EnumDAdvise(out enumAdvise: IEnumStatData): HResult;

begin
  if FAdviseHolder = nil then
    Result := OLE_E_ADVISENOTSUPPORTED
  else
    Result := FAdviseHolder.EnumAdvise(enumAdvise);
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTDataObject.EnumFormatEtc(Direction: Integer; out EnumFormatEtc: IEnumFormatEtc): HResult;

var
  NewList: TEnumFormatEtc;

begin
  Result := E_FAIL;
  if Direction = DATADIR_GET then
  begin
    NewList := TEnumFormatEtc.Create(FOwner, FormatEtcArray);
    EnumFormatEtc := NewList as IEnumFormatEtc;
    Result := S_OK;
  end
  else
    EnumFormatEtc := nil;
  if EnumFormatEtc = nil then
    Result := OLE_S_USEREG;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTDataObject.GetCanonicalFormatEtc(const FormatEtc: TFormatEtc; out FormatEtcOut: TFormatEtc): HResult;

begin
  Result := DATA_S_SAMEFORMATETC;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTDataObject.GetData(const FormatEtcIn: TFormatEtc; out Medium: TStgMedium): HResult;

// Data is requested by clipboard or drop target. This method dispatchs the call
// depending on the data being requested.

var
  I: Integer;
  Data: PVTReference;

begin
  // The tree reference format is always supported and returned from here.
  if FormatEtcIn.cfFormat = CF_VTREFERENCE then
  begin
    // Note: this format is not used while flushing the clipboard to avoid a dangling reference
    //       when the owner tree is destroyed before the clipboard data is replaced with something else.
    if tsClipboardFlushing in FOwner.FStates then
      Result := E_FAIL
    else
    begin
      Medium.hGlobal := GlobalAlloc(GHND or GMEM_SHARE, SizeOf(TVTReference));
      Data := GlobalLock(Medium.hGlobal);
      Data.Process := GetCurrentProcessID;
      Data.Tree := FOwner;
      GlobalUnlock(Medium.hGlobal);
      Medium.tymed := TYMED_HGLOBAL;
      Medium.unkForRelease := nil;
      Result := S_OK;
    end;
  end
  else
  begin
    try
      // See if we accept this type and if not get the correct return value.
      Result := QueryGetData(FormatEtcIn);
      if Result = S_OK then
      begin
        for I := 0 to High(FormatEtcArray) do
        begin
          if EqualFormatEtc(FormatEtcIn, FormatEtcArray[I]) then
          begin
            if not RenderInternalOLEData(FormatEtcIn, Medium, Result) then
              Result := FOwner.RenderOLEData(FormatEtcIn, Medium, FForClipboard);
            Break;
          end;
        end
      end
    except
      FillChar(Medium, SizeOf(Medium), #0);
      Result := E_FAIL;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTDataObject.GetDataHere(const FormatEtc: TFormatEtc; out Medium: TStgMedium): HResult;

begin
  Result := E_NOTIMPL;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTDataObject.QueryGetData(const FormatEtc: TFormatEtc): HResult;

var
  I: Integer;

begin
  Result := DV_E_CLIPFORMAT;
  for I := 0 to High(FFormatEtcArray) do
  begin
    if FormatEtc.cfFormat = FFormatEtcArray[I].cfFormat then
    begin
      if (FormatEtc.tymed and FFormatEtcArray[I].tymed) <> 0 then
      begin
        if FormatEtc.dwAspect = FFormatEtcArray[I].dwAspect then
        begin
          if FormatEtc.lindex = FFormatEtcArray[I].lindex then
          begin
            Result := S_OK;
            Break;
          end
          else
            Result := DV_E_LINDEX;
        end
        else
          Result := DV_E_DVASPECT;
      end
      else
        Result := DV_E_TYMED;
    end;
  end
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTDataObject.SetData(const FormatEtc: TFormatEtc; var Medium: TStgMedium; DoRelease: BOOL): HResult;

// Allows dynamic adding to the IDataObject during its existance. Most noteably it is used to implement
// IDropSourceHelper and allows to set a special format for optimized moves during a shell transfer.

var
  Index: integer;
  LocalStgMedium: PStgMedium;

begin
  // See if we already have a format of that type available.
  Index := FindFormatEtc(FormatEtc, FormatEtcArray);
  if Index > - 1 then
  begin
    // Just use the TFormatEct in the Array after releasing the data.    
    LocalStgMedium := FindInternalStgMedium(FormatEtcArray[Index].cfFormat);
    if Assigned(LocalStgMedium) then
    begin
      ReleaseStgMedium(LocalStgMedium^);
      FillChar(LocalStgMedium^, SizeOf(LocalStgMedium^), #0);
    end;
  end
  else
  begin
    // It is a new format so create a new TFormatCollectionItem, copy the
    // FormatEtc parameter into the new object and and put it in the list.
    SetLength(FFormatEtcArray, Length(FormatEtcArray) + 1);
    FormatEtcArray[High(FormatEtcArray)] := FormatEtc;

    // Create a new InternalStgMedium and initialize it and associate it with the format.
    SetLength(FInternalStgMediumArray, Length(InternalStgMediumArray) + 1);
    InternalStgMediumArray[High(InternalStgMediumArray)].Format := FormatEtc.cfFormat;
    LocalStgMedium := @InternalStgMediumArray[High(InternalStgMediumArray)].Medium;
    FillChar(LocalStgMedium^, SizeOf(LocalStgMedium^), #0);
  end;

  if DoRelease then
  begin
    // We are simply being given the data and we take control of it.          
    LocalStgMedium^ := Medium;
    Result := S_OK
  end
  else
  begin
    // We need to reference count or copy the data and keep our own references to it.
    Result := StgMediumIncRef(Medium, LocalStgMedium^, True, Self as IDataObject);

    // Can get a circular reference if the client calls GetData then calls SetData with the same StgMedium.
    // Because the unkForRelease for the IDataObject can be marshalled it is necessary to get pointers that
    // can be correctly compared. See the IDragSourceHelper article by Raymond Chen at MSDN.
    if Assigned(LocalStgMedium.unkForRelease) then
    begin
      if CanonicalIUnknown(Self) = CanonicalIUnknown(IUnknown(LocalStgMedium.unkForRelease)) then
        IUnknown(LocalStgMedium.unkForRelease) := nil; // release the interface
    end;
  end;

  // Tell all registered advice sinks about the data change.
  if Assigned(FAdviseHolder) then
    FAdviseHolder.SendOnDataChange(Self as IDataObject, 0, 0);
end;

//----------------- TVTDragManager -------------------------------------------------------------------------------------

constructor TVTDragManager.Create(AOwner: TBaseVirtualTree);

begin
  inherited Create;
  FOwner := AOwner;

  // Create an instance  of the drop target helper interface. This will fail but not harm on systems which do
  // not support this interface (everything below Windows 2000);
  CoCreateInstance(CLSID_DragDropHelper, nil, CLSCTX_INPROC_SERVER, IID_IDropTargetHelper, FDropTargetHelper);
end;

//----------------------------------------------------------------------------------------------------------------------

destructor TVTDragManager.Destroy;

begin
  // Set the owner's reference to us to nil otherwise it will access an invalid pointer
  // after our desctruction is complete.  
  Pointer(FOwner.FDragManager) := nil;
  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTDragManager.GetDataObject: IDataObject;

begin
  // When the owner tree starts a drag operation then it gets a data object here to pass it to the OLE subsystem.
  // In this case there is no local reference to a data object and one is created (but not stored).
  // If there is a local reference then the owner tree is currently the drop target and the stored interface is
  // that of the drag initiator. 
  if Assigned(FDataObject) then
    Result := FDataObject
  else
  begin
    Result := FOwner.DoCreateDataObject;
    if Result = nil then
      Result := TVTDataObject.Create(FOwner, False) as IDataObject;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTDragManager.GetDragSource: TBaseVirtualTree;

begin
  Result := FDragSource;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTDragManager.GetDropTargetHelperSupported: Boolean;

begin
  Result := Assigned(FDropTargetHelper);
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTDragManager.GetIsDropTarget: Boolean;

begin
  Result := FIsDropTarget;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTDragManager.DragEnter(const DataObject: IDataObject; KeyState: Integer; Pt: TPoint;
  var Effect: Integer): HResult;

begin
  FDataObject := DataObject; 
  FIsDropTarget := True;
  
  if Assigned(FDropTargetHelper) then
    FDropTargetHelper.DragEnter(FOwner.Handle, DataObject, Pt, Effect);

  FDragSource := FOwner.GetTreeFromDataObject(DataObject);
  Result := FOwner.DragEnter(KeyState, Pt, Effect);
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTDragManager.DragLeave: HResult;

begin
  if Assigned(FDropTargetHelper) then
    FDropTargetHelper.DragLeave;

  FOwner.DragLeave;
  FIsDropTarget := False;
  FDragSource := nil;
  FDataObject := nil;
  Result := NOERROR;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTDragManager.DragOver(KeyState: Integer; Pt: TPoint; var Effect: Integer): HResult;

begin
  if Assigned(FDropTargetHelper) then
    FDropTargetHelper.DragOver(Pt, Effect);

  Result := FOwner.DragOver(FDragSource, KeyState, dsDragMove, Pt, Effect);
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTDragManager.Drop(const DataObject: IDataObject; KeyState: Integer; Pt: TPoint;
  var Effect: Integer): HResult;

begin
  if Assigned(FDropTargetHelper) then
    FDropTargetHelper.Drop(DataObject, Pt, Effect);

  Result := FOwner.DragDrop(DataObject, KeyState, Pt, Effect);
  FIsDropTarget := False;
  FDataObject := nil;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTDragManager.GiveFeedback(Effect: Integer): HResult;

begin
  Result := DRAGDROP_S_USEDEFAULTCURSORS;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTDragManager.QueryContinueDrag(EscapePressed: BOOL; KeyState: Integer): HResult;

var
  RButton,
  LButton: Boolean;

begin
  LButton := (KeyState and MK_LBUTTON) <> 0;
  RButton := (KeyState and MK_RBUTTON) <> 0;

  // Drag'n drop canceled by pressing both mouse buttons or Esc?
  if (LButton and RButton) or EscapePressed then
    Result := DRAGDROP_S_CANCEL
  else
    // drag'n drop finished?
    if not (LButton or RButton) then
      Result := DRAGDROP_S_DROP
    else
      Result := S_OK;
end;

//----------------- TVirtualTreeHintWindow -----------------------------------------------------------------------------

var
  // This variable is necessary to coordinate the complex interaction between different hints in the application
  // and animated hints in our own class. Under certain conditions it can happen that our hint window is destroyed
  // while it is still in the animation loop.
  HintWindowDestroyed: Boolean;
  
constructor TVirtualTreeHintWindow.Create(AOwner: TComponent);

begin
  inherited;
  
  FBackground := TBitmap.Create;
  FBackground.PixelFormat := pf32Bit;
  FDrawBuffer := TBitmap.Create;
  FDrawBuffer.PixelFormat := pf32Bit;
  FTarget := TBitmap.Create;
  FTarget.PixelFormat := pf32Bit;

  DoubleBuffered := False; // we do our own buffering
  HintWindowDestroyed := False;
end;

//----------------------------------------------------------------------------------------------------------------------

destructor TVirtualTreeHintWindow.Destroy;

begin
  HintWindowDestroyed := True;

  FTarget.Free;
  FDrawBuffer.Free;
  FBackground.Free;
  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualTreeHintWindow.AnimationCallback(Step, StepSize: Integer; Data: Pointer): Boolean;

begin
  Result := not HintWindowDestroyed and IsWindowVisible(Handle);
  if Result then
  begin
    InternalPaint(Step, StepSize);
    // We have to allow certain messages to be processed normally for various reasons.
    // This introduces another problem however if this hint window is destroyed
    // while it is still in the animation loop. A global variable keeps track of
    // that case. This is reliable because we can only have one (internal) hint window.
    Application.ProcessMessages;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeHintWindow.InternalPaint(Step, StepSize: Integer);

  //--------------- local functions -------------------------------------------

  procedure DoShadowBlend(DC: HDC; R: TRect; Alpha: Integer);

  // Helper routine for shadow blending to shorten the parameter list in frequent calls.

  begin
    AlphaBlend(0, DC, R, Point(0, 0), bmConstantAlphaAndColor,  Alpha, clBlack);
  end;

  //---------------------------------------------------------------------------

  procedure DrawHintShadow(Canvas: TCanvas; ShadowSize: Integer);

  var
    R: TRect;

  begin
    // Bottom shadow.
    R := Rect(ShadowSize, Height - ShadowSize, Width, Height);
    DoShadowBlend(Canvas.Handle, R, 5);
    Inc(R.Left);
    Dec(R.Right);
    Dec(R.Bottom);
    DoShadowBlend(Canvas.Handle, R, 10);
    Inc(R.Left);
    Dec(R.Right);
    Dec(R.Bottom);
    DoShadowBlend(Canvas.Handle, R, 20);
    Inc(R.Left);
    Dec(R.Right);
    Dec(R.Bottom);
    DoShadowBlend(Canvas.Handle, R, 35);
    Inc(R.Left);
    Dec(R.Right);
    Dec(R.Bottom);
    DoShadowBlend(Canvas.Handle, R, 50);
    // Right shadow.
    R := Rect(Width - ShadowSize, ShadowSize, Width, Height - ShadowSize);
    DoShadowBlend(Canvas.Handle, R, 5);
    Inc(R.Top);
    Dec(R.Right);
    DoShadowBlend(Canvas.Handle, R, 10);
    Inc(R.Top);
    Dec(R.Right);
    DoShadowBlend(Canvas.Handle, R, 20);
    Inc(R.Top);
    Dec(R.Right);
    DoShadowBlend(Canvas.Handle, R, 35);
    Inc(R.Top);
    Dec(R.Right);
    DoShadowBlend(Canvas.Handle, R, 50);
  end;

  //--------------- end local functions ---------------------------------------

var
  R: TRect;
  Y: Integer;
  S: WideString;
  DrawFormat: Cardinal;
  Shadow: Integer;

begin
  if MMXAvailable then
    Shadow := ShadowSize
  else
    Shadow := 0;

  with FHintData, FDrawBuffer do
  begin
    // Do actual painting only in the very first run.
    if Step = 0 then
    begin
      // If the given node is nil then we have to display a header hint.
      if (Node = nil) or (Tree.FHintMode <> hmToolTip) then
      begin
        {$ifndef COMPILER_5_UP}
          Canvas.Font := HintFont;
        {$else}
          Canvas.Font := Screen.HintFont;
        {$endif COMPILER_5_UP}
        Y := 2;
      end
      else
      begin
        Tree.GetTextInfo(Node, Column, Canvas.Font, R, S);
        Y := (R.Top - R.Bottom - Shadow + Self.Height) div 2;
      end;

      with ClientRect do
        R := Rect(0, 0, Width - Shadow, Height - Shadow);

      if (Tree is TCustomVirtualDrawTree) and Assigned(Node) then
      begin
        // The draw tree has by default no hint text so let it draw the hint itself.
        (Tree as TCustomVirtualDrawTree).DoDrawHint(Canvas, Node, R, Column);
      end
      else
        with Canvas do
        begin
          // Still force tooltip back and text color.
          Font.Color := clInfoText;
          Pen.Color := clBlack;
          Brush.Color := clInfoBk;
          {$ifdef COMPILER_5_UP}
            Rectangle(R);
          {$else}
            with R do
              Rectangle(Left, Top, Right, Bottom);
          {$endif COMPILER_5_UP}

          // Determine text position and don't forget the border.
          InflateRect(R, -Tree.FTextMargin - 1, -1);
          if BidiMode <> bdLeftToRight then
          begin
            DrawFormat := DT_TOP or DT_RIGHT or DT_RTLREADING;
            Inc(R.Right);
          end
          else
            DrawFormat := DT_TOP or DT_LEFT;
          SetBkMode(Handle, Windows.TRANSPARENT);
          R.Top := Y;
          DrawTextW(Handle, PWideChar(HintText), Length(HintText), R, DrawFormat, False);
        end;
    end;
  end;

  if StepSize > 0 then
  begin
    if FHintData.Tree.DoGetAnimationType = hatFade then
    begin
      with FTarget do
        BitBlt(Canvas.Handle, 0, 0, Width, Height, FBackground.Canvas.Handle, 0, 0, SRCCOPY);
      // Main image.
      AlphaBlend(FDrawBuffer.Canvas.Handle, FTarget.Canvas.Handle, Rect(0, 0, Width - Shadow, Height - Shadow),
        Point(0, 0), bmConstantAlpha,  MulDiv(Step, 256, FadeAnimationStepCount), 0);

      if Shadow > 0 then
        DrawHintShadow(FTarget.Canvas, Shadow);
      BitBlt(Canvas.Handle, 0, 0, Width, Height, FTarget.Canvas.Handle, 0, 0, SRCCOPY);
    end
    else
    begin
      // Slide is done by blitting "step" lines of the lower part of the hint window
      // and fill the rest with the screen background.

      // 1) blit hint bitmap to the hint canvas
      BitBlt(Canvas.Handle, 0, 0, Width - Shadow, Step, FDrawBuffer.Canvas.Handle, 0, Height - Step, SRCCOPY);
      // 2) blit background rest to hint canvas
      if Step <= Shadow then
        Step := 0
      else
        Dec(Step, Shadow);
      BitBlt(Canvas.Handle, 0, Step, Width, Height - Step, FBackground.Canvas.Handle, 0, Step, SRCCOPY);
    end;
  end
  else
    // Last step during slide or the only step without animation.
    if FHintData.Tree.DoGetAnimationType <> hatFade then
    begin
      if Shadow > 0 then
      begin
        with FBackground do
          BitBlt(Canvas.Handle, 0, 0, Width - Shadow, Height - Shadow, FDrawBuffer.Canvas.Handle, 0, 0, SRCCOPY);

        DrawHintShadow(FBackground.Canvas, Shadow);
        BitBlt(Canvas.Handle, 0, 0, Width, Height, FBackground.Canvas.Handle, 0, 0, SRCCOPY);
      end
      else
        BitBlt(Canvas.Handle, 0, 0, Width, Height, FDrawBuffer.Canvas.Handle, 0, 0, SRCCOPY);
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeHintWindow.CMTextChanged(var Message: TMessage);

begin
  // swallow this message to prevent the ancestor from resizing the window (we don't use the caption anyway)
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeHintWindow.WMEraseBkgnd(var Message: TWMEraseBkgnd);

// The control is fully painted by own code so don't erase its background as this causes flickering.

begin
  Message.Result := 1;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeHintWindow.WMNCPaint(var Message: TMessage);

// The control is fully painted by own code so don't paint any borders.

begin
  Message.Result := 0;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeHintWindow.CreateParams(var Params: TCreateParams);

begin
  inherited CreateParams(Params);
  
  with Params do
  begin
    Style := WS_POPUP;
    ExStyle := ExStyle and not WS_EX_CLIENTEDGE;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeHintWindow.Paint;

begin
  InternalPaint(0, 0);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeHintWindow.ActivateHint(Rect: TRect; const AHint: string);

var
  DC: HDC;

begin
  // Do not allow to enter the animation loop recursively.
  if tsInAnimation in FHintData.Tree.FStates then
    Application.CancelHint
  else
  begin
    SetWindowPos(Handle, 0, Rect.Left, Rect.Top, Width, Height, SWP_HIDEWINDOW or SWP_NOACTIVATE or SWP_NOZORDER);
    UpdateBoundsRect(Rect);

    if Rect.Top + Height > Screen.DesktopHeight then
      Rect.Top := Screen.DesktopHeight - Height;
    if Rect.Top < Screen.DesktopTop then
      Rect.Top := Screen.DesktopTop;
    if Rect.Left + Width > Screen.DesktopWidth then
      Rect.Left := Screen.DesktopWidth - Width;
    if Rect.Left < Screen.DesktopLeft then
      Rect.Left := Screen.DesktopLeft;

    // adjust sizes of bitmaps
    FDrawBuffer.Width := Width;
    FDrawBuffer.Height := Height;
    FBackground.Width := Width;
    FBackground.Height := Height;
    FTarget.Width := Width;
    FTarget.Height := Height;

    FHintData.Tree.Update;

    // capture screen
    DC := GetDC(0);
    try
      with Rect do
        BitBlt(FBackground.Canvas.Handle, 0, 0, Width, Height, DC, Left, Top, SRCCOPY);
    finally
      ReleaseDC(0, DC);
    end;
                          
    SetWindowPos(Handle, HWND_TOPMOST, Rect.Left, Rect.Top, Width, Height, SWP_SHOWWINDOW or SWP_NOACTIVATE);
    with FHintData.Tree do
      case DoGetAnimationType of
        hatNone:
          InvalidateRect(Self.Handle, nil, False);
        hatFade:
          begin
            // Make sure the window is not drawn unanimated.
            ValidateRect(Self.Handle, nil);
            // Empirically determined animation duration shows that fading needs about twice as much time as
            // sliding to show a comparable visual effect.
            Animate(FadeAnimationStepCount, 2 * FAnimationDuration, AnimationCallback, nil);
          end;
        hatSlide:
          begin
            // Make sure the window is not drawn unanimated.
            ValidateRect(Self.Handle, nil);
            Animate(Self.Height, FAnimationDuration, AnimationCallback, nil);
          end;
      end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualTreeHintWindow.CalcHintRect(MaxWidth: Integer; const AHint: string; AData: Pointer): TRect;

var
  TM: TTextMetric;
  
begin
  // The hint window does not need any bidi mode setting but the caller of this method (TApplication.ActivateHint)
  // does some unneccessary actions if the hint window is not left-to-right.
  // The text alignment is based on the bidi mode passed in the hint data, hence we can
  // simply set the window's mode to left-to-right (it might have been modified by the caller, if the
  // tree window is right-to-left aligned).
  BidiMode := bdLeftToRight;

  FHintData := PHintData(AData)^;

  with FHintData do
  begin
    // The draw tree gets its hint size by the application (but only if not a header hint is about to show).
    // This size has already been determined in CMHintShow.
    if (Tree is TCustomVirtualDrawTree) and Assigned(Node) then
      Result := HintRect 
    else
    begin
      if Column <= NoColumn then
      begin
        BidiMode := Tree.BidiMode;
        Alignment := Tree.Alignment;
      end
      else
      begin
        BidiMode := Tree.Header.Columns[Column].BidiMode;
        Alignment := Tree.Header.Columns[Column].Alignment;
      end;

      if BidiMode <> bdLeftToRight then
        ChangeBidiModeAlignment(Alignment);

      if (Node = nil) or (Tree.FHintMode <> hmToolTip) then
      begin
        {$ifndef COMPILER_5_UP}
          Canvas.Font := HintFont
        {$else}
          Canvas.Font := Screen.HintFont
        {$endif COMPILER_5_UP}
      end
      else
      begin
        Canvas.Font := Tree.Font;
        if Tree is TCustomVirtualStringTree then
          with TCustomVirtualStringTree(Tree) do
            DoPaintText(Node, Self.Canvas, Column, ttNormal);
      end;

      GetTextMetrics(Canvas.Handle, TM);
      FTextHeight := TM.tmHeight;

      if Length(DefaultHint) > 0 then
        HintText := DefaultHint
      else
        if Tree.HintMode = hmToolTip then
          HintText := Tree.DoGetNodeToolTip(Node, Column)
        else
          HintText := Tree.DoGetNodeHint(Node, Column);

      if Length(HintText) = 0 then
        Result := Rect(0, 0, 0, 0)
      else
      begin
        if Assigned(Node) and (Tree.FHintMode = hmToolTip) then
        begin
          // Hint for a node.
          Result := Tree.GetDisplayRect(Node, Column, True, True);
          if toShowHorzGridLines in Tree.TreeOptions.PaintOptions then
            Dec(Result.Bottom);
          // Include a one pixel border.
          InflateRect(Result, 1, 1);
          // Make the coordinates relative. They will again be offset by the caller code.
          OffsetRect(Result, -Result.Left - 1, -Result.Top - 1);
        end
        else
        begin
          // Hint for a header.
          // Start with the base size of the hint in client coordinates.
          Result := Rect(0, 0, MaxWidth, FTextHeight);
          // Calculate the true size of the text rectangle.
          DrawTextW(Canvas.Handle, PWideChar(HintText), Length(HintText), Result, DT_CALCRECT, True);
          // The height of the text plus 2 pixels vertical margin plus the border determine the hint window height.
          Inc(Result.Bottom, 6);
          // The text is centered horizontally with usual text margin for left and right borders (plus border).
          Inc(Result.Right, 2 * Tree.FTextMargin + 2);
        end;

        // Add some pixels for the shadow if MMX is available for blending.
        if MMXAvailable then
        begin
          Inc(Result.Right, ShadowSize);
          Inc(Result.Bottom, ShadowSize);
        end;
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualTreeHintWindow.IsHintMsg(var Msg: TMsg): Boolean;

// The VCL is a bit too generous when telling that an existing hint can be cancelled, need to specify further here.

begin
  Result := inherited IsHintMsg(Msg) and HandleAllocated and IsWindowVisible(Handle);
  if Result and (Msg.Message = WM_NCMOUSEMOVE) then
    Result := False;
end;

//----------------- TVTDragImage ---------------------------------------------------------------------------------------

constructor TVTDragImage.Create(AOwner: TBaseVirtualTree);

begin
  FOwner := AOwner;
  FTransparency := 128;
  FPreBlendBias := 0;
  FPostBlendBias := 0;
  FFade := False;
  FRestriction := dmrNone;
  FColorKey := clNone;
end;

//----------------------------------------------------------------------------------------------------------------------

destructor TVTDragImage.Destroy;

begin
  EndDrag;
  
  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTDragImage.GetVisible: Boolean;

// Returns True if the internal drag image is used (i.e. the system does not natively support drag images) and
// the internal image is currently visible on screen.

begin
  Result := FStates * [disHidden, disInDrag, disPrepared, disSystemSupport] = [disInDrag, disPrepared];
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTDragImage.InternalShowDragImage(ScreenDC: HDC);

// Frequently called helper routine to actually do the blend and put it onto the screen.
// Only used if the system does not support drag images.

var
  BlendMode: TBlendMode;

begin
  with FAlphaImage do
    BitBlt(Canvas.Handle, 0, 0, Width, Height, FBackImage.Canvas.Handle, 0, 0, SRCCOPY);
  if not FFade and (FColorKey = clNone) then
    BlendMode := bmConstantAlpha
  else
    BlendMode := bmMasterAlpha;
  with FDragImage do
    AlphaBlend(Canvas.Handle, FAlphaImage.Canvas.Handle, Rect(0, 0, Width, Height), Point(0, 0), BlendMode,
      FTransparency, FPostBlendBias);

  with FAlphaImage do
    BitBlt(ScreenDC, FImagePosition.X, FImagePosition.Y, Width, Height, Canvas.Handle, 0, 0, SRCCOPY);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTDragImage.MakeAlphaChannel(Source, Target: TBitmap);

// Helper method to create a proper alpha channel in Target (which must be in 32 bit pixel format), depending
// on the settings for the drag image and the color values in Source.
// Only used if the system does not support drag images.

type
  PBGRA = ^TBGRA;
  TBGRA = packed record
    case Boolean of
      False:
        (Color: Cardinal);
      True:
        (BGR: array[0..2] of Byte;
         Alpha: Byte);
  end;

var
  Color,
  ColorKeyRef: COLORREF;
  UseColorKey: Boolean;
  SourceRun,
  TargetRun: PBGRA;
  X, Y,
  MaxDimension,
  HalfWidth,
  HalfHeight: Integer;
  T: Extended;

begin
  UseColorKey := ColorKey <> clNone;
  ColorKeyRef := ColorToRGB(ColorKey) and $FFFFFF;
  // Color values are in the form BGR (red on LSB) while bitmap colors are in the form ARGB (blue on LSB)
  // hence we have to swap red and blue in the color key.
  with TBGRA(ColorKeyRef) do
  begin
    X := BGR[0];
    BGR[0] := BGR[2];
    BGR[2] := X;
  end;

  with Target do
  begin
    MaxDimension := Max(Width, Height);

    HalfWidth := Width div 2;
    HalfHeight := Height div 2;
    for Y := 0 to Height - 1 do
    begin
      TargetRun := Scanline[Y];
      SourceRun := Source.Scanline[Y];
      for X := 0 to Width - 1 do
      begin
        Color := SourceRun.Color and $FFFFFF;
        if UseColorKey and (Color = ColorKeyRef) then
          TargetRun.Alpha := 0
        else
        begin
          // If the color is not the given color key (or none is used) then do full calculation of a bell curve.
          T := exp(-8 * Sqrt(Sqr((X - HalfWidth) / MaxDimension) + Sqr((Y - HalfHeight) / MaxDimension)));
          TargetRun.Alpha := Round(255 * T);
        end;
        Inc(SourceRun);
        Inc(TargetRun);
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTDragImage.DragTo(P: TPoint; ForceRepaint: Boolean): Boolean;

// Moves the drag image to a new position, which is determined from the passed point P and the previous
// mouse position.
// ForceRepaint is True if something on the screen changed and the back image must be refreshed.

var
  ScreenDC: HDC;
  DeltaX,
  DeltaY: Integer;
  
  // optimized drag image move support
  RSamp1,
  RSamp2,       // newly added parts from screen which will be overwritten
  RDraw1,
  RDraw2,       // parts to be restored to screen
  RScroll,
  RClip: TRect; // ScrollDC of the existent background

begin 
  // Determine distances to move the drag image. Take care for restrictions.
  case FRestriction of
    dmrHorizontalOnly:
      begin
        DeltaX := FLastPosition.X - P.X;
        DeltaY := 0;
      end;
    dmrVerticalOnly:
      begin
        DeltaX := 0;
        DeltaY := FLastPosition.Y - P.Y;
      end;
  else // dmrNone
    DeltaX := FLastPosition.X - P.X;
    DeltaY := FLastPosition.Y - P.Y;
  end;

  Result := (DeltaX <> 0) or (DeltaY <> 0) or ForceRepaint;
  if Result then
  begin
    if Visible then
    begin
      // All this stuff is only called if we have to handle the drag image ourselves. If the system supports
      // drag image then this is all never executed. 
      ScreenDC := GetDC(0);
      try
        if (Abs(DeltaX) >= FDragImage.Width) or (Abs(DeltaY) >= FDragImage.Height) or ForceRepaint then
        begin
          // If moved more than image size then just restore old screen and blit image to new position.
          BitBlt(ScreenDC, FImagePosition.X, FImagePosition.Y, FBackImage.Width, FBackImage.Height,
            FBackImage.Canvas.Handle, 0, 0, SRCCOPY);

          if ForceRepaint then
            UpdateWindow(FOwner.Handle);
      
          Inc(FImagePosition.X, -DeltaX);
          Inc(FImagePosition.Y, -DeltaY);

          BitBlt(FBackImage.Canvas.Handle, 0, 0, FBackImage.Width, FBackImage.Height, ScreenDC, FImagePosition.X,
            FImagePosition.Y, SRCCOPY);
        end
        else
        begin
          // overlapping copy
          FillDragRectangles(FDragImage.Width, FDragImage.Height, DeltaX, DeltaY, RClip, RScroll, RSamp1, RSamp2, RDraw1,
            RDraw2);

          with FBackImage.Canvas do
          begin
            // restore uncovered areas of the screen
            if DeltaX = 0 then
            begin
              with RDraw2 do
                BitBlt(ScreenDC, FImagePosition.X + Left, FImagePosition.Y + Top, Right, Bottom, Handle, Left, Top,
                  SRCCOPY);
            end
            else
            begin
              if DeltaY = 0 then
              begin
                with RDraw1 do
                  BitBlt(ScreenDC, FImagePosition.X + Left, FImagePosition.Y + Top, Right, Bottom, Handle, Left, Top,
                    SRCCOPY);
              end
              else
              begin
                with RDraw1 do
                  BitBlt(ScreenDC, FImagePosition.X + Left, FImagePosition.Y + Top, Right, Bottom, Handle, Left, Top,
                    SRCCOPY);
                with RDraw2 do
                  BitBlt(ScreenDC, FImagePosition.X + Left, FImagePosition.Y + Top, Right, Bottom, Handle, Left, Top,
                    SRCCOPY);
              end;
            end;

            // move existent background
            ScrollDC(Handle, DeltaX, DeltaY, RScroll, RClip, 0, nil);

            Inc(FImagePosition.X, -DeltaX);
            Inc(FImagePosition.Y, -DeltaY);

            // Get first and second additional rectangle from screen.
            if DeltaX = 0 then
            begin
              with RSamp2 do
                BitBlt(Handle, Left, Top, Right, Bottom, ScreenDC, FImagePosition.X + Left, FImagePosition.Y + Top,
                  SRCCOPY);
            end
            else
              if DeltaY = 0 then
              begin
                with RSamp1 do
                  BitBlt(Handle, Left, Top, Right, Bottom, ScreenDC, FImagePosition.X + Left, FImagePosition.Y + Top,
                    SRCCOPY);
              end
              else
              begin
                with RSamp1 do
                  BitBlt(Handle, Left, Top, Right, Bottom, ScreenDC, FImagePosition.X + Left, FImagePosition.Y + Top,
                    SRCCOPY);
                with RSamp2 do
                  BitBlt(Handle, Left, Top, Right, Bottom, ScreenDC, FImagePosition.X + Left, FImagePosition.Y + Top,
                    SRCCOPY);
              end;
          end;
        end;
        InternalShowDragImage(ScreenDC);
      finally
        ReleaseDC(0, ScreenDC);
      end;
    end;
    FLastPosition.X := P.X;
    FLastPosition.Y := P.Y;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTDragImage.EndDrag;

begin
  HideDragImage;
  FStates := FStates - [disInDrag, disPrepared];
  
  FBackImage.Free;
  FBackImage := nil;
  FDragImage.Free;
  FDragImage := nil;
  FAlphaImage.Free;
  FAlphaImage := nil;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTDragImage.GetDragImageRect: TRect;

// Returns the current size and position of the drag image (screen coordinates).

begin
  if Visible then
  begin
    with FBackImage do
      Result := Rect(FImagePosition.X, FImagePosition.Y, FImagePosition.X + Width, FImagePosition.Y + Height);
  end
  else
    Result := Rect(0, 0, 0, 0);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTDragImage.HideDragImage;

var
  ScreenDC: HDC;

begin
  if Visible then
  begin
    Include(FStates, disHidden);
    ScreenDC := GetDC(0);
    try
      // restore screen
      with FBackImage do
        BitBlt(ScreenDC, FImagePosition.X, FImagePosition.Y, Width, Height, Canvas.Handle, 0, 0, SRCCOPY);
    finally
      ReleaseDC(0, ScreenDC);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTDragImage.PrepareDrag(DragImage: TBitmap; ImagePosition, HotSpot: TPoint; const DataObject: IDataObject);

// Creates all necessary structures to do alpha blended dragging using the given image.
// ImagePostion and Hotspot are given in screen coordinates. The first determines where to place the drag image while
// the second is the initial mouse position.
// This method also determines whether the system supports drag images natively. If so then only minimal structures
// are created.

var
  Width,
  Height: Integer;
  DragSourceHelper: IDragSourceHelper;
  DragInfo: TSHDragImage;

begin
  Width := DragImage.Width;
  Height := DragImage.Height;

  // Determine whether the system supports the drag helper interfaces.
  if Assigned(DataObject) and Succeeded(CoCreateInstance(CLSID_DragDropHelper, nil, CLSCTX_INPROC_SERVER,
    IID_IDragSourceHelper, DragSourceHelper)) then
  begin
    Include(FStates, disSystemSupport);
    
    // Supply the drag source helper with our drag image.
    DragInfo.sizeDragImage.cx := Width;
    DragInfo.sizeDragImage.cy := Height;
    DragInfo.ptOffset.x := Width div 2;
    DragInfo.ptOffset.y := Height div 2;
    DragInfo.hbmpDragImage := CopyImage(DragImage.Handle, IMAGE_BITMAP, Width, Height, LR_COPYRETURNORG);
    DragInfo.ColorRef := ColorToRGB(FColorKey);
    if not Succeeded(DragSourceHelper.InitializeFromBitmap(DragInfo, DataObject)) then
    begin
      DeleteObject(DragInfo.hbmpDragImage);
      Exclude(FStates, disSystemSupport);
    end;
  end
  else
    Exclude(FStates, disSystemSupport);

  if MMXAvailable and not (disSystemSupport in FStates) then
  begin
    FLastPosition := HotSpot;

    FDragImage := TBitmap.Create;
    FDragImage.PixelFormat := pf32Bit;
    FDragImage.Width := Width;
    FDragImage.Height := Height;

    FAlphaImage := TBitmap.Create;
    FAlphaImage.PixelFormat := pf32Bit;
    FAlphaImage.Width := Width;
    FAlphaImage.Height := Height;

    FBackImage := TBitmap.Create;
    FBackImage.PixelFormat := pf32Bit;
    FBackImage.Width := Width;
    FBackImage.Height := Height;

    // Copy the given drag image and apply pre blend bias if required.
    if FPreBlendBias = 0 then
      with FDragImage do
        BitBlt(Canvas.Handle, 0, 0, Width, Height, DragImage.Canvas.Handle, 0, 0, SRCCOPY)
    else
      AlphaBlend(DragImage.Canvas.Handle, FDragImage.Canvas.Handle, Rect(0, 0, Width, Height), Point(0, 0),
        bmConstantAlpha, 255, FPreBlendBias);

    // Create a proper alpha channel also if no fading is required (transparent parts).
    MakeAlphaChannel(DragImage, FDragImage);

    FImagePosition := ImagePosition;

    // Initially the drag image is hidden and will be shown during the immediately following DragEnter event.
    FStates := FStates + [disInDrag, disHidden, disPrepared];
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTDragImage.RecaptureBackground(Tree: TBaseVirtualTree; R: TRect; VisibleRegion: HRGN;
  CaptureNCArea, ReshowDragImage: Boolean);

// Notification by the drop target tree to update the background image because something in the tree has changed.
// Note: The passed rectangle is given in client coordinates of the current drop target tree (given in Tree).
//       The caller does not check if the given rectangle is actually within the drag image. Hence this method must do
//       all the checks.
// This method does nothing if the system manages the drag image.

var
  DragRect,
  ClipRect: TRect;
  PaintTarget: TPoint;
  PaintOptions: TVTInternalPaintOptions;
  ScreenDC: HDC;

begin
  // Recapturing means we want the tree to paint the new part into our back bitmap instead to the screen.
  if Visible then
  begin
    // Create the minimum rectangle to be recaptured.
    MapWindowPoints(Tree.Handle, 0, R, 2);
    DragRect := GetDragImageRect;
    IntersectRect(R, R, DragRect);

    OffsetRgn(VisibleRegion, -DragRect.Left, -DragRect.Top);

    // The target position for painting in the drag image is relative and can be determined from screen coordinates too.
    PaintTarget.X := R.Left - DragRect.Left;
    PaintTarget.Y := R.Top - DragRect.Top;

    // The source rectangle is determined by the offsets in the tree.
    MapWindowPoints(0, Tree.Handle, R, 2);
    OffsetRect(R, -Tree.FOffsetX, -Tree.FOffsetY);

    // Finally let the tree paint the relevant part and upate the drag image on screen.
    PaintOptions := [poBackground, poColumnColor, poDrawFocusRect, poDrawDropMark, poDrawSelection, poGridLines];
    with FBackImage do
    begin
      ClipRect.TopLeft := PaintTarget;
      ClipRect.Right := ClipRect.Left + R.Right - R.Left;
      ClipRect.Bottom := ClipRect.Top + R.Bottom - R.Top;
      Tree.LimitPaintingToArea(Canvas, ClipRect, VisibleRegion);
      Tree.PaintTree(Canvas, R, PaintTarget, PaintOptions);

      if CaptureNCArea then
      begin
        // For the non-client area we only need the visible region of the window as limit for painting.
        SelectClipRgn(Canvas.Handle, VisibleRegion);
        // Since WM_PRINT cannot be given a position where to draw we simply move the window origin and
        // get the same effect.
        GetWindowRect(Tree.Handle, ClipRect);
        SetWindowOrgEx(Canvas.Handle, DragRect.Left - ClipRect.Left, DragRect.Top - ClipRect.Top, nil);
        Tree.Perform(WM_PRINT, Integer(Canvas.Handle), PRF_NONCLIENT);
        SetWindowOrgEx(Canvas.Handle, 0, 0, nil);
      end;
      SelectClipRgn(Canvas.Handle, 0);
      
      if ReshowDragImage then
      begin
        GDIFlush;
        ScreenDC := GetDC(0);
        try
          InternalShowDragImage(ScreenDC);
        finally
          ReleaseDC(0, ScreenDC);
        end;
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTDragImage.ShowDragImage;

// Shows the drag image after it has been hidden by HideDragImage.
// Note: there might be a new background now.
// Also this method does nothing if the system manages the drag image.

var
  ScreenDC: HDC;

begin
  if FStates * [disInDrag, disHidden, disPrepared, disSystemSupport] = [disInDrag, disHidden, disPrepared] then
  begin
    Exclude(FStates, disHidden);

    GDIFlush;
    ScreenDC := GetDC(0);
    try
      BitBlt(FBackImage.Canvas.Handle, 0, 0, FBackImage.Width, FBackImage.Height, ScreenDC, FImagePosition.X,
        FImagePosition.Y, SRCCOPY);

      InternalShowDragImage(ScreenDC);
    finally
      ReleaseDC(0, ScreenDC);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTDragImage.WillMove(P: TPoint): Boolean;

// This method determines whether the drag image would "physically" move when DragTo would be called with the same
// target point.
// Always returns False if the system drag image support is available.
 
var
  DeltaX,
  DeltaY: Integer;

begin
  Result := Visible;
  if Result then
  begin
    // Determine distances to move the drag image. Take care for restrictions.
    case FRestriction of
      dmrHorizontalOnly:
        begin
          DeltaX := FLastPosition.X - P.X;
          DeltaY := 0;
        end;
      dmrVerticalOnly:
        begin
          DeltaX := 0;
          DeltaY := FLastPosition.Y - P.Y;
        end;
    else // dmrNone
      DeltaX := FLastPosition.X - P.X;
      DeltaY := FLastPosition.Y - P.Y;
    end;

    Result := (DeltaX <> 0) or (DeltaY <> 0);
  end;
end;

//----------------- TVirtualTreeColumn ---------------------------------------------------------------------------------

constructor TVirtualTreeColumn.Create(Collection: TCollection);

begin
  inherited Create(Collection);

  FWidth := 50;
  FLastWidth := 50;
  FMinWidth := 10;
  FMaxWidth := 10000;
  FImageIndex := -1;
  FMargin := 4;
  FSpacing := 4;
  FText := '';
  FOptions := DefaultColumnOptions;

  FPosition := Owner.Count - 1;
  // Read parent bidi mode and color values as default values.
  ParentBiDiModeChanged;
  ParentColorChanged;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualTreeColumn.GetLeft: Integer;

begin
  Result := FLeft + Owner.Header.Treeview.FOffsetX;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualTreeColumn.IsBiDiModeStored: Boolean;

begin
  Result := not (coParentBiDiMode in FOptions);
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualTreeColumn.IsColorStored: Boolean;

begin
  Result := not (coParentColor in FOptions);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumn.SetAlignment(const Value: TAlignment);

begin
  if FAlignment <> Value then
  begin
    FAlignment := Value;
    Changed(False);
    // Setting the alignment affects also the tree, hence invalidate it too.
    Owner.Header.TreeView.Invalidate;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumn.SetBiDiMode(Value: TBiDiMode);

begin
  if Value <> FBiDiMode then
  begin
    FBiDiMode := Value;
    Exclude(FOptions, coParentBiDiMode);
    Changed(False);
    // Setting the alignment affects also the tree, hence invalidate it too.
    Owner.Header.TreeView.Invalidate;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumn.SetColor(const Value: TColor);

begin
  if FColor <> Value then
  begin
    FColor := Value;
    Exclude(FOptions, coParentColor);
    Changed(False);
    Owner.Header.TreeView.Invalidate;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumn.SetImageIndex(Value: TImageIndex);

begin
  if Value <> FImageIndex then
  begin
    FImageIndex := Value;
    Changed(False);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumn.SetLayout(Value: TVTHeaderColumnLayout);

begin
  if FLayout <> Value then
  begin
    FLayout := Value;
    Changed(False);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumn.SetMargin(Value: Integer);

begin
  // Compatibility setting for -1.
  if Value < 0 then
    Value := 4;
  if FMargin <> Value then
  begin
    FMargin := Value;
    Changed(False);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumn.SetMaxWidth(Value: Integer);

begin
  if Value < FMinWidth then
    Value := FMinWidth;
  if Value > 10000 then
    Value := 10000;
  FMaxWidth := Value;
  SetWidth(FWidth);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumn.SetMinWidth(Value: Integer);

begin
  if Value < 0 then
    Value := 0;
  if Value > FMaxWidth then
    Value := FMaxWidth;
  FMinWidth := Value;
  SetWidth(FWidth);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumn.SetOptions(Value: TVTColumnOptions);

var
  ToBeSet,
  ToBeCleared: TVTColumnOptions;
  VisibleChanged,
  ColorChanged: Boolean;

begin
  if FOptions <> Value then
  begin
    ToBeCleared := FOptions - Value;
    ToBeSet := Value - FOptions;

    FOptions := Value;

    VisibleChanged := coVisible in (ToBeSet + ToBeCleared);
    ColorChanged := coParentColor in ToBeSet;

    if coParentBidiMode in ToBeSet then
     ParentBiDiModeChanged;
    if ColorChanged then
     ParentColorChanged;

    Changed(False);
    // Need to repaint and adjust the owner tree too.
    with Owner, Header.Treeview do
      if not (csLoading in ComponentState) and (VisibleChanged or ColorChanged) and (UpdateCount = 0) then
      begin
        Invalidate;
        if VisibleChanged then
          UpdateHorizontalScrollBar(False);
      end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumn.SetPosition(Value: TColumnPosition);

begin
  if Value >= TColumnPosition(Collection.Count) then
    Value := Collection.Count - 1;
  if FPosition <> Value then
    with Owner do
    begin
      InitializePositionArray;
      AdjustPosition(Self, Value);
      UpdatePositions;
      // need to repaint and adjust the owner tree too
      with FHeader do
      begin
        if not (csLoading in FOwner.ComponentState) and (UpdateCount = 0) then
        begin
          Treeview.CancelEditNode;
          Invalidate(Self);
          Treeview.Invalidate;
          Treeview.UpdateHorizontalScrollBar(False);
        end;
      end;
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumn.SetSpacing(Value: Integer);

begin
  if FSpacing <> Value then
  begin
    FSpacing := Value;
    Changed(False);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumn.SetStyle(Value: TVirtualTreeColumnStyle);

begin
  if FStyle <> Value then
  begin
    FStyle := Value;
    Changed(False);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumn.SetText(const Value: WideString);

begin
  if FText <> Value then
  begin
    FText := Value;
    Changed(False);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumn.SetWidth(Value: Integer);

begin
  if Value < FMinWidth then
    Value := FMinWidth;
  if Value > FMaxWidth then
    Value := FMaxWidth;

  if FWidth <> Value then
  begin
    FLastWidth := FWidth;
    with Owner, Header do
    begin
      if not (hoAutoResize in FOptions) or (Index <> FAutoSizeIndex) then
      begin
        FWidth := Value;
        UpdatePositions;
      end;
      if not (csLoading in Treeview.ComponentState) and (UpdateCount = 0) then
      begin
        if hoAutoResize in FOptions then
          AdjustAutoSize(Index);
        Treeview.DoColumnResize(Index);
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumn.ComputeHeaderLayout(DC: HDC; const Client: TRect; UseHeaderGlyph, UseSortGlyph: Boolean;
  var HeaderGlyphPos, SortGlyphPos: TPoint; var TextBounds: TRect);

// The layout of a column header is determined by a lot of factors. This method takes them all into account and
// determines all necessary positions and bounds:
// - for the header text
// - the header glyph
// - the sort glyph

var
  TextSize: TSize;
  TextPos,
  ClientSize,
  HeaderGlyphSize,
  SortGlyphSize: TPoint;
  CurrentAlignment: TAlignment;
  MinLeft,
  MaxRight,
  TextSpacing: Integer;
  UseText: Boolean;

begin
  UseText := Length(FText) > 0;
  // If nothing is to show then don't waste time with useless preparation.
  if not (UseText or UseHeaderGlyph or UseSortGlyph) then
    Exit;

  CurrentAlignment := FAlignment;
  if FBidiMode <> bdLeftToRight then
    ChangeBiDiModeAlignment(CurrentAlignment);

  // Calculate sizes of the involved items.
  ClientSize := Point(Client.Right - Client.Left, Client.Bottom - Client.Top);
  with Owner, Header do
  begin
    if UseHeaderGlyph then
      HeaderGlyphSize := Point(FImages.Width, FImages.Height)
    else
      HeaderGlyphSize := Point(0, 0);
    if UseSortGlyph then
    begin
      SortGlyphSize := Point(UtilityImages.Width, UtilityImages.Height);
      // In any case, the sort glyph is vertically centered.
      SortGlyphPos.Y := (ClientSize.Y - SortGlyphSize.Y) div 2;
    end
    else
      SortGlyphSize := Point(0, 0);
  end;

  if UseText then
  begin
    GetTextExtentPoint32W(DC, PWideChar(FText), Length(FText), TextSize);
    Inc(TextSize.cx, 2);
    TextBounds := Rect(0, 0, TextSize.cx, TextSize.cy);
    TextSpacing := FSpacing;
  end
  else
  begin
    TextSpacing := 0;
    TextSize.cx := 0;
    TextSize.cy := 0;
  end;

  // Check first for the special case where nothing is shown except the sort glyph.
  if UseSortGlyph and not (UseText or UseHeaderGlyph) then
  begin
    // Center the sort glyph in the available area if nothing else is there.
    SortGlyphPos := Point((ClientSize.X - SortGlyphSize.X) div 2, (ClientSize.Y - SortGlyphSize.Y) div 2);
  end
  else
  begin
    // Determine extents of text and glyph and calculate positions which are clear from the layout.
    if (Layout in [blGlyphLeft, blGlyphRight]) or not UseHeaderGlyph then
    begin
      HeaderGlyphPos.Y := (ClientSize.Y - HeaderGlyphSize.Y) div 2;
      TextPos.Y := (ClientSize.Y - TextSize.cy) div 2;
    end
    else
    begin
      if Layout = blGlyphTop then
      begin
        HeaderGlyphPos.Y := (ClientSize.Y - HeaderGlyphSize.Y - TextSize.cy - TextSpacing) div 2;
        TextPos.Y := HeaderGlyphPos.Y + HeaderGlyphSize.Y + TextSpacing;
      end
      else
      begin
        TextPos.Y := (ClientSize.Y - HeaderGlyphSize.Y - TextSize.cy - TextSpacing) div 2;
        HeaderGlyphPos.Y := TextPos.Y + TextSize.cy + TextSpacing;
      end;
    end;

    // Each alignment needs special consideration. 
    case CurrentAlignment of
      taLeftJustify:
        begin
          MinLeft := FMargin;
          if UseSortGlyph and (FBidiMode <> bdLeftToRight) then
          begin
            // In RTL context is the sort glyph placed on the left hand side.
            SortGlyphPos.X := MinLeft;
            Inc(MinLeft, SortGlyphSize.X + FSpacing);
          end;
          if Layout in [blGlyphTop, blGlyphBottom] then
          begin
            // Header glyph is above or below text, so both must be considered when calculating
            // the left positition of the sort glyph (if it is on the right hand side).
            TextPos.X := MinLeft;
            if UseHeaderGlyph then
            begin
              HeaderGlyphPos.X := (ClientSize.X - HeaderGlyphSize.X) div 2;
              if HeaderGlyphPos.X < MinLeft then
                HeaderGlyphPos.X := MinLeft;
              MinLeft := Max(TextPos.X + TextSize.cx + TextSpacing, HeaderGlyphPos.X + HeaderGlyphSize.X + FSpacing);
            end
            else
              MinLeft := TextPos.X + TextSize.cx + TextSpacing;
          end
          else
          begin
            // Everything is lined up. TextSpacing might be 0 if there is no text.
            // This simplifies the calculation because no extra tests are necessary.
            if UseHeaderGlyph and (Layout = blGlyphLeft) then
            begin
              HeaderGlyphPos.X := MinLeft;
              Inc(MinLeft, HeaderGlyphSize.X + FSpacing);
            end;
            TextPos.X := MinLeft;
            Inc(MinLeft, TextSize.cx + TextSpacing);
            if UseHeaderGlyph and (Layout = blGlyphRight) then
            begin
              HeaderGlyphPos.X := MinLeft;
              Inc(MinLeft, HeaderGlyphSize.X + FSpacing);
            end;
          end;
          if UseSortGlyph and (FBidiMode = bdLeftToRight) then
            SortGlyphPos.X := MinLeft;
        end;
      taCenter:
        begin
          if Layout in [blGlyphTop, blGlyphBottom] then
          begin
            HeaderGlyphPos.X := (ClientSize.X - HeaderGlyphSize.X) div 2;
            TextPos.X := (ClientSize.X - TextSize.cx) div 2;
            if UseSortGlyph then
              Dec(TextPos.X, SortGlyphSize.X div 2);
          end
          else
          begin
            MinLeft := (ClientSize.X - HeaderGlyphSize.X - TextSpacing - TextSize.cx) div 2;
            if UseHeaderGlyph and (Layout = blGlyphLeft) then
            begin
              HeaderGlyphPos.X := MinLeft;
              Inc(MinLeft, HeaderGlyphSize.X + TextSpacing);
            end;
            TextPos.X := MinLeft;
            Inc(MinLeft, TextSize.cx + TextSpacing);
            if UseHeaderGlyph and (Layout = blGlyphRight) then
              HeaderGlyphPos.X := MinLeft;
          end;
          if UseHeaderGlyph then
          begin
            MinLeft := Min(HeaderGlyphPos.X, TextPos.X);
            MaxRight := Max(HeaderGlyphPos.X + HeaderGlyphSize.X, TextPos.X + TextSize.cx);
          end
          else
          begin
            MinLeft := TextPos.X;
            MaxRight := TextPos.X + TextSize.cx;
          end;
          // Place the sort glyph directly to the left or right of the larger item.
          if UseSortGlyph then
            if FBidiMode = bdLeftToRight then
            begin
              // Sort glyph on the right hand side.
              SortGlyphPos.X := MaxRight + FSpacing;
            end
            else
            begin
              // Sort glyph on the left hand side.
              SortGlyphPos.X := MinLeft - FSpacing - SortGlyphSize.X;
            end;
        end;
    else
      // taRightJustify
      MaxRight := ClientSize.X - FMargin;
      if UseSortGlyph and (FBidiMode = bdLeftToRight) then
      begin
        // In LTR context is the sort glyph placed on the right hand side.
        Dec(MaxRight, SortGlyphSize.X);
        SortGlyphPos.X := MaxRight;
        Dec(MaxRight, FSpacing);
      end;
      if Layout in [blGlyphTop, blGlyphBottom] then
      begin
        TextPos.X := MaxRight - TextSize.cx;
        if UseHeaderGlyph then
        begin
          HeaderGlyphPos.X := (ClientSize.X - HeaderGlyphSize.X) div 2;
          if HeaderGlyphPos.X + HeaderGlyphSize.X + FSpacing > MaxRight then
            HeaderGlyphPos.X := MaxRight - HeaderGlyphSize.X - FSpacing;
          MaxRight := Min(TextPos.X - TextSpacing, HeaderGlyphPos.X - FSpacing);
        end
        else
          MaxRight := TextPos.X - TextSpacing;
      end
      else
      begin
        // Everything is lined up. TextSpacing might be 0 if there is no text.
        // This simplifies the calculation because no extra tests are necessary.
        if UseHeaderGlyph and (Layout = blGlyphRight) then
        begin
          HeaderGlyphPos.X := MaxRight -  HeaderGlyphSize.X;
          MaxRight := HeaderGlyphPos.X - FSpacing;
        end;
        TextPos.X := MaxRight - TextSize.cx;
        MaxRight := TextPos.X - TextSpacing;
        if UseHeaderGlyph and (Layout = blGlyphLeft) then
        begin
          HeaderGlyphPos.X := MaxRight - HeaderGlyphSize.X;
          MaxRight := HeaderGlyphPos.X - FSpacing;
        end;
      end;
      if UseSortGlyph and (FBidiMode <> bdLeftToRight) then
        SortGlyphPos.X := MaxRight - SortGlyphSize.X;
    end;
  end;

  // Once the position of each element is determined there remains only one but important step.
  // The horizontal positions of every element must be adjusted so that it always fits into the
  // given header area. This is accomplished by shorten the text appropriately.

  // These are the maximum bounds. Nothing goes beyond them.
  MinLeft := FMargin;
  MaxRight := ClientSize.X - FMargin;
  if UseSortGlyph then
  begin
    if FBidiMode = bdLeftToRight then
    begin
      // Sort glyph on the right hand side. 
      if SortGlyphPos.X + SortGlyphSize.X > MaxRight then
        SortGlyphPos.X := MaxRight - SortGlyphSize.X;
      MaxRight := SortGlyphPos.X - FSpacing;
    end;

    // Consider also the left side of the sort glyph regardless of the bidi mode. 
    if SortGlyphPos.X < MinLeft then
      SortGlyphPos.X := MinLeft;
    // Left border needs only adjustment if the sort glyph marks the left border.
    if FBidiMode <> bdLeftToRight then
      MinLeft := SortGlyphPos.X + SortGlyphSize.X + FSpacing;

    // Finally transform sort glyph to its actual position.
    with SortGlyphPos do
    begin
      Inc(X, Client.Left);
      Inc(Y, Client.Top);
    end;
  end;
  if UseHeaderGlyph then
  begin
    if HeaderGlyphPos.X + HeaderGlyphSize.X > MaxRight then
      HeaderGlyphPos.X := MaxRight - HeaderGlyphSize.X;
    if Layout = blGlyphRight then
      MaxRight := HeaderGlyphPos.X - FSpacing;
    if HeaderGlyphPos.X < MinLeft then
      HeaderGlyphPos.X := MinLeft;
    if Layout = blGlyphLeft then
      MinLeft := HeaderGlyphPos.X + HeaderGlyphSize.X + FSpacing;
    // Finally transform header glyph to its actual position.
    with HeaderGlyphPos do
    begin
      Inc(X, Client.Left);
      Inc(Y, Client.Top);
    end;
  end;
  if UseText then
  begin
    if TextPos.X < MinLeft then
      TextPos.X := MinLeft;
    OffsetRect(TextBounds, TextPos.X, TextPos.Y);
    if TextBounds.Right > MaxRight then
      TextBounds.Right := MaxRight;
    OffsetRect(TextBounds, Client.Left, Client.Top);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumn.DefineProperties(Filer: TFiler);

begin
  inherited;

  // Must define a new name for the properties otherwise the VCL will try to load the wide string
  // without asking us and screws it completely up.
  Filer.DefineProperty('WideText', ReadText, WriteText, FText <> '');
  Filer.DefineProperty('WideHint', ReadHint, WriteHint, FHint <> '');
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumn.GetAbsoluteBounds(var Left, Right: Integer);

// Returns the column's left and right bounds in header coordinates, that is, independant of the scrolling position.

begin
  Left := FLeft;
  Right := FLeft + FWidth;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualTreeColumn.GetDisplayName: string;

// Returns the column text if it only contains ANSI characters, otherwise the column id is returned because the IDE
// still cannot handle Unicode strings.

var
  I: Integer;

begin
  // Check if the text of the column contains characters > 255
  I := 1;
  while I <= Length(FText) do
  begin
    if Ord(FText[I]) > 255 then
      Break;
    Inc(I);
  end;

  if I > Length(FText) then
    Result := FText // implicit conversion
  else
    Result := Format('Column %d', [Index]);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumn.ReadText(Reader: TReader);

begin
  case Reader.NextValue of
    vaLString, vaString:
      SetText(Reader.ReadString);
  else
    SetText(Reader.ReadWideString);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualTreeColumn.GetOwner: TVirtualTreeColumns;

begin
  Result := Collection as TVirtualTreeColumns;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumn.ReadHint(Reader: TReader);

begin
  case Reader.NextValue of
    vaLString, vaString:
      FHint := Reader.ReadString;
  else
    FHint := Reader.ReadWideString;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumn.WriteHint(Writer: TWriter);

begin
  Writer.WriteWideString(FHint);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumn.WriteText(Writer: TWriter);

begin
  Writer.WriteWideString(FText);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumn.Assign(Source: TPersistent);

begin
  if Source is TVirtualTreeColumn then
  begin
    BiDiMode := TVirtualTreeColumn(Source).BiDiMode;
    ImageIndex := TVirtualTreeColumn(Source).ImageIndex;
    Layout := TVirtualTreeColumn(Source).Layout;
    Margin := TVirtualTreeColumn(Source).Margin;
    MaxWidth := TVirtualTreeColumn(Source).MaxWidth;
    MinWidth := TVirtualTreeColumn(Source).MinWidth;
    Position := TVirtualTreeColumn(Source).Position;
    Spacing := TVirtualTreeColumn(Source).Spacing;
    Style := TVirtualTreeColumn(Source).Style;
    Text := TVirtualTreeColumn(Source).Text;
    Hint := TVirtualTreeColumn(Source).Hint;
    Width := TVirtualTreeColumn(Source).Width;
    Options := TVirtualTreeColumn(Source).Options;
    Alignment := TVirtualTreeColumn(Source).Alignment;
    Color := TVirtualTreeColumn(Source).Color;

    Changed(False);
  end
  else
    inherited Assign(Source);
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualTreeColumn.GetRect: TRect;

// Returns the rectangle this column occupies in the header (relative to (0, 0) of the non-client area).

begin
  with TVirtualTreeColumns(GetOwner).FHeader do
    Result := Treeview.FHeaderRect;
  Inc(Result.Left, FLeft);
  Result.Right := Result.Left + FWidth;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumn.LoadFromStream(const Stream: TStream; Version: Integer);

  //--------------- local function --------------------------------------------

  function ConvertOptions(Value: Cardinal): TVTColumnOptions;

  // Converts the given raw value which represents column options for possibly older
  // formats to the current format.
  
  begin
    if Version > 1 then
      Result := TVTColumnOptions(Byte(Value))
    else
    begin
      // In version 2 coParentColor has been added. This needs an option shift for older stream formats.
      // The first (lower) 4 options remain as they are.
      Result := TVTColumnOptions(Byte(Value) and $F);
      Value := (Value and not $F) shl 1;
      Result := Result + TVTColumnOptions(Byte(Value));
    end;
  end;

  //--------------- end local function ----------------------------------------

var
  Dummy: Integer;
  S: WideString;

begin
  with Stream do
  begin
    ReadBuffer(Dummy, SizeOf(Dummy));
    SetLength(S, Dummy);
    ReadBuffer(PWideChar(S)^, 2 * Dummy);
    Text := S;
    ReadBuffer(Dummy, SizeOf(Dummy));
    SetLength(FHint, Dummy);
    ReadBuffer(PWideChar(FHint)^, 2 * Dummy);
    ReadBuffer(Dummy, SizeOf(Dummy));
    Width := Dummy;
    ReadBuffer(Dummy, SizeOf(Dummy));
    MinWidth := Dummy;
    ReadBuffer(Dummy, SizeOf(Dummy));
    MaxWidth := Dummy;
    ReadBuffer(Dummy, SizeOf(Dummy));
    Style := TVirtualTreeColumnStyle(Dummy);
    ReadBuffer(Dummy, SizeOf(Dummy));
    ImageIndex := Dummy;
    ReadBuffer(Dummy, SizeOf(Dummy));
    Layout := TVTHeaderColumnLayout(Dummy);
    ReadBuffer(Dummy, SizeOf(Dummy));
    Margin := Dummy;
    ReadBuffer(Dummy, SizeOf(Dummy));
    Spacing := Dummy;
    ReadBuffer(Dummy, SizeOf(Dummy));
    BiDiMode := TBiDiMode(Dummy);

    ReadBuffer(Dummy, SizeOf(Dummy));
    Options := ConvertOptions(Dummy);

    if Version > 0 then
    begin
      // Parts which have been introduced/changed with header stream version 1+.
      ReadBuffer(Dummy, SizeOf(Dummy));
      Tag := Dummy;
      ReadBuffer(Dummy, SizeOf(Dummy));
      Alignment := TAlignment(Dummy);

      if Version > 1 then
      begin
        ReadBuffer(Dummy, SizeOf(Dummy));
        Color := TColor(Dummy);
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumn.ParentBiDiModeChanged;

var
  Columns: TVirtualTreeColumns;

begin
  if coParentBiDiMode in FOptions then
  begin
    Columns := GetOwner as TVirtualTreeColumns;
    if Assigned(Columns) and (FBidiMode <> Columns.FHeader.Treeview.BiDiMode) then
    begin
      FBiDiMode := Columns.FHeader.Treeview.BiDiMode;
      Changed(False);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumn.ParentColorChanged;

var
  Columns: TVirtualTreeColumns;

begin
  if coParentColor in FOptions then
  begin
    Columns := GetOwner as TVirtualTreeColumns;
    if Assigned(Columns) and (FColor <> Columns.FHeader.Treeview.Color) then
    begin
      FColor := Columns.FHeader.Treeview.Color;
      Changed(False);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumn.RestoreLastWidth;

begin
  TVirtualTreeColumns(GetOwner).AnimatedResize(Index, FLastWidth);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumn.SaveToStream(const Stream: TStream);

var
  Dummy: Integer;

begin
  with Stream do
  begin
    Dummy := Length(FText);
    WriteBuffer(Dummy, SizeOf(Dummy));
    WriteBuffer(PWideChar(FText)^, 2 * Dummy);
    Dummy := Length(FHint);
    WriteBuffer(Dummy, SizeOf(Dummy));
    WriteBuffer(PWideChar(FHint)^, 2 * Dummy);
    WriteBuffer(FWidth, SizeOf(FWidth));
    WriteBuffer(FMinWidth, SizeOf(FMinWidth));
    WriteBuffer(FMaxWidth, SizeOf(FMaxWidth));
    Dummy := Ord(FStyle);
    WriteBuffer(Dummy, SizeOf(Dummy));
    Dummy := FImageIndex;
    WriteBuffer(Dummy, SizeOf(Dummy));
    Dummy := Ord(FLayout);
    WriteBuffer(Dummy, SizeOf(Dummy));
    WriteBuffer(FMargin, SizeOf(FMargin));
    WriteBuffer(FSpacing, SizeOf(FSpacing));
    Dummy := Ord(FBiDiMode);
    WriteBuffer(Dummy, SizeOf(Dummy));
    Dummy := Byte(FOptions);
    WriteBuffer(Dummy, SizeOf(Dummy));

    // parts introduce with stream version 1
    WriteBuffer(FTag, SizeOf(Dummy));
    Dummy := Cardinal(FAlignment);
    WriteBuffer(Dummy, SizeOf(Dummy));

    // parts introduce with stream version 2
    Dummy := Integer(FColor);
    WriteBuffer(Dummy, SizeOf(Dummy));
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualTreeColumn.UseRightToLeftReading: Boolean;

begin
  Result := FBiDiMode <> bdLeftToRight;
end;

//----------------- TVirtualTreeColumns --------------------------------------------------------------------------------

constructor TVirtualTreeColumns.Create(AOwner: TVTHeader);

var
  ColumnClass: TVirtualTreeColumnClass;

begin
  FHeader := AOwner;

  // Determine column class to be used in the header.
  ColumnClass := AOwner.FOwner.GetColumnClass;
  // The owner tree always returns the default tree column class if not changed by application/descentants.
  inherited Create(ColumnClass);

  FHeaderBitmap := TBitmap.Create;
  FHoverIndex := NoColumn;
  FDownIndex := NoColumn;
  FClickIndex := NoColumn;
  FDropTarget := NoColumn;
  FTrackIndex := NoColumn;
end;

//----------------------------------------------------------------------------------------------------------------------

destructor TVirtualTreeColumns.Destroy;

begin
  FHeaderBitmap.Free;
  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumns.DrawButtonText(DC: HDC; Caption: WideString; Bounds: TRect; Enabled, Hot: Boolean;
  DrawFormat: Cardinal);

var
  TextSpace: Integer;
  Size: TSize;

begin
  // Do we need to shorten the caption due to limited space?
  GetTextExtentPoint32W(DC, PWideChar(Caption), Length(Caption), Size);
  TextSpace := Bounds.Right - Bounds.Left;
  if TextSpace < Size.cx then
    Caption := ShortenString(DC, Caption, TextSpace, DT_RTLREADING and DrawFormat <> 0);

  SetBkMode(DC, TRANSPARENT);
  if not Enabled then
  begin
    OffsetRect(Bounds, 1, 1);
    SetTextColor(DC, ColorToRGB(clBtnHighlight));
    DrawTextW(DC, PWideChar(Caption), Length(Caption), Bounds, DrawFormat, False);
    OffsetRect(Bounds, -1, -1);
    SetTextColor(DC, ColorToRGB(clBtnShadow));
    DrawTextW(DC, PWideChar(Caption), Length(Caption), Bounds, DrawFormat, False);
  end
  else
  begin
    if Hot then
      SetTextColor(DC, ColorToRGB(clBtnShadow))
    else                            
      SetTextColor(DC, ColorToRGB(FHeader.FFont.Color));
    DrawTextW(DC, PWideChar(Caption), Length(Caption), Bounds, DrawFormat, False);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualTreeColumns.GetItem(Index: TColumnIndex): TVirtualTreeColumn;

begin
  Result := TVirtualTreeColumn(inherited GetItem(Index));
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualTreeColumns.GetNewIndex(P: TPoint; var OldIndex: TColumnIndex): Boolean;

var
  NewIndex: Integer;

begin
  Result := False;
  // convert to local coordinates
  Inc(P.Y, FHeader.FHeight);
  NewIndex := ColumnFromPosition(P);
  if NewIndex <> OldIndex then
  begin
    if OldIndex > NoColumn then
      FHeader.Invalidate(Items[OldIndex]);
    OldIndex := NewIndex;
    if OldIndex > NoColumn then
      FHeader.Invalidate(Items[OldIndex]);
    Result := True;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumns.SetItem(Index: TColumnIndex; Value: TVirtualTreeColumn);

begin
  inherited SetItem(Index, Value);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumns.AdjustAutoSize(CurrentIndex: TColumnIndex; Force: Boolean = False);

// Called only if the header is in auto-size mode which means a column needs to be so large
// that it fills all the horizontal space not occupied by the other columns.
// CurrentIndex (if not InvalidColumn) describes which column has just been resized.

var
  NewValue,
  AutoIndex,
  Index,
  RestWidth: Integer;

begin
  if Count > 0 then
  begin
    // Determine index to be used for auto resizing. This is usually given by the owner's AutoSizeIndex, but
    // could be different if the column whose resize caused the invokation here is either the auto column itself
    // or visually to the right of the auto size column.
    AutoIndex := FHeader.FAutoSizeIndex;
    if (AutoIndex < 0) or (AutoIndex >= Count) then
      AutoIndex := Count - 1;
    if (CurrentIndex > NoColumn) and
      (Items[CurrentIndex].Position >= Items[AutoIndex].Position) then
    begin
      // The given index is the either the auto size column itself or visually to its right.
      // Use the next column instead if there is one.
      AutoIndex := GetNextVisibleColumn(CurrentIndex);
    end;

    if AutoIndex >= 0 then
    begin
      with FHeader.Treeview do
      begin
        if HandleAllocated then
          RestWidth := ClientWidth
        else
          RestWidth := Width;
      end;

      // go through all columns and calculate the rest space remaining
      for Index := 0 to Count - 1 do
        if (Index <> AutoIndex) and (coVisible in Items[Index].FOptions) then
          Dec(RestWidth, Items[Index].Width);

      with Items[AutoIndex] do
      begin
        NewValue := Max(MinWidth, Min(MaxWidth, RestWidth));
        if Force or (FWidth <> NewValue) then
        begin
          FWidth := NewValue;
          UpdatePositions;
          FHeader.Treeview.DoColumnResize(AutoIndex);
        end;
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualTreeColumns.AdjustDownColumn(P: TPoint): TColumnIndex;

// Determines the column from the given position and returns it. If this column is allowed to be clicked then
// it is also kept for later use.

begin
  // Convert to local coordinates.
  Inc(P.Y, FHeader.FHeight);
  Result := ColumnFromPosition(P);
  if (Result > NoColumn) and (Result <> FDownIndex) and (coAllowClick in Items[Result].FOptions) and
    (coEnabled in Items[Result].FOptions) then
  begin
    if FDownIndex > NoColumn then
      FHeader.Invalidate(Items[FDownIndex]);
    FDownIndex := Result;
    FHeader.Invalidate(Items[FDownIndex]);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualTreeColumns.AdjustHoverColumn(P: TPoint): Boolean;

// Determines the new hover column index and returns True if the index actually changed else False.

begin
  Result := GetNewIndex(P, FHoverIndex);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumns.AdjustPosition(Column: TVirtualTreeColumn; Position: Cardinal);

// Reorders the column position array so that the given column gets the given position.

var
  OldPosition: Cardinal;

begin
  OldPosition := Column.Position;
  if OldPosition <> Position then
  begin
    if OldPosition < Position then
    begin
      // column will be moved up so move down other entries
      Move(FPositionToIndex[OldPosition + 1], FPositionToIndex[OldPosition], (Position - OldPosition) * SizeOf(Cardinal));
    end
    else
    begin
      // column will be moved down so move up other entries
      Move(FPositionToIndex[Position], FPositionToIndex[Position + 1], (OldPosition - Position) * SizeOf(Cardinal));
    end;
    FPositionToIndex[Position] := Column.Index;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumns.AnimatedResize(Column: Integer; NewWidth: Integer);

// Resizes the given column animated by scrolling the window DC.

var
  OldWidth: Integer;
  DC: HDC;
  I,
  Steps,
  DX: Integer;
  HeaderScrollRect,
  ScrollRect,
  R: TRect;

  NewBrush,
  LastBrush: HBRUSH;
  
begin
  OldWidth := Items[Column].Width;
  // Nothing to do if the width is the same.
  if OldWidth <> NewWidth then
  begin
    DC := GetWindowDC(FHeader.Treeview.Handle);
    with FHeader.Treeview do
    try
      Steps := 32;
      DX := (NewWidth - OldWidth) div Steps;

      // Determination of the scroll rectangle is a bit complicated since we neither want
      // to scroll the scrollbars nor the border of the treeview window.
      HeaderScrollRect := FHeaderRect;
      ScrollRect := HeaderScrollRect;
      // Exclude the header itself from scrolling.
      ScrollRect.Top := ScrollRect.Bottom;
      ScrollRect.Bottom := ScrollRect.Top + ClientHeight;
      ScrollRect.Right := ScrollRect.Left + ClientWidth;
      with Items[Column] do
        Inc(ScrollRect.Left, FLeft + FWidth);
      HeaderScrollRect.Left := ScrollRect.Left;
      HeaderScrollRect.Right := ScrollRect.Right;

      // When the new width is larger than avoid artefacts on the left hand side
      // by deleting a small stripe
      if NewWidth > OldWidth then
      begin
        R := ScrollRect;
        NewBrush := CreateSolidBrush(ColorToRGB(Color));
        LastBrush := SelectObject(DC, NewBrush);
        R.Right := R.Left + DX;
        FillRect(DC, R, NewBrush);
        SelectObject(DC, LastBrush);
        DeleteObject(NewBrush);
      end
      else
      begin
        Inc(HeaderScrollRect.Left, DX);
        Inc(ScrollRect.Left, DX);
      end;

      for I := 0 to Steps - 1 do
      begin
        ScrollDC(DC, DX, 0, HeaderScrollRect, HeaderScrollRect, 0, nil);
        Inc(HeaderScrollRect.Left, DX);
        ScrollDC(DC, DX, 0, ScrollRect, ScrollRect, 0, nil);
        Inc(ScrollRect.Left, DX);
        Sleep(1);
      end;
    finally
      ReleaseDC(Handle, DC);
    end;
    Items[Column].Width := NewWidth;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualTreeColumns.GetColumnAndBounds(P: TPoint; var ColumnLeft, ColumnRight: Integer;
  Relative: Boolean = True): Integer;

// Returns the column where the mouse is currently in as well as the left and right bound of
// this column (Left and Right are undetermined if no column is involved).

var
  I: Integer;

begin
  Result := InvalidColumn;
  if Relative then
    ColumnLeft := FHeader.Treeview.FOffsetX
  else
    ColumnLeft := 0;
  for I := 0 to Count - 1 do
    with Items[FPositionToIndex[I]] do
      if coVisible in FOptions then
      begin
        ColumnRight := ColumnLeft + FWidth;
        if P.X < ColumnRight then
        begin
          Result := FPositionToIndex[I];
          Exit;
        end;
        ColumnLeft := ColumnRight;
      end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualTreeColumns.GetOwner: TPersistent;

begin
  Result := FHeader;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumns.HandleClick(P: TPoint; Button: TMouseButton; Force: Boolean);

// Generates a click event if the mouse button has been released over the same column it was pressed first.
// Alternatively, Force might be set to True to indicate that the down index does not matter (right, middle and
// double click).

var
  NewClickIndex: Integer;

begin
  // convert to local coordinates
  Inc(P.Y, FHeader.FHeight);
  NewClickIndex := ColumnFromPosition(P);
  if (NewClickIndex > NoColumn) and (coAllowClick in Items[NewClickIndex].FOptions) and
    ((NewClickIndex = FDownIndex) or Force) then
  begin
    FClickIndex := NewClickIndex;
    FHeader.Treeview.DoHeaderClick(NewClickIndex, Button, FHeader.GetShiftState, P.X, P.Y);
    FHeader.Invalidate(Items[NewClickIndex]);
  end
  else
    FClickIndex := NoColumn;

  if (FClickIndex > NoColumn) and (FClickIndex <> NewClickIndex) then
    FHeader.Invalidate(Items[FClickIndex]);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumns.InitializePositionArray;

// Ensures that the column position array contains as much entries as columns are defined.
// The array is resized and initialized with default values if needed.

var
  I, OldSize: Integer;
  Changed: Boolean;

begin
  if Count <> Length(FPositionToIndex) then
  begin
    OldSize := Length(FPositionToIndex);
    SetLength(FPositionToIndex, Count);
    if Count > OldSize then
    begin
      // New items have been added, just set their position to the same as their index.
      for I := OldSize to Count - 1 do
        FPositionToIndex[I] := I;
    end
    else
    begin
      // Items have been deleted, so reindex remaining entries by decrementing values larger than the highest
      // possible index until no entry is higher than this limit.
      repeat
        Changed := False;
        for I := 0 to Count - 1 do
          if FPositionToIndex[I] >= Count then
          begin
            Dec(FPositionToIndex[I]);
            Changed := True;
          end;
      until not Changed;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumns.Update(Item: TCollectionItem);

begin
  // This is the only place which gets notified when a new column has been added or removed
  // and we need this event to adjust the column position array.
  InitializePositionArray;
  UpdatePositions;

  // The first column which is created is by definition also the main column.
  if (Count > 0) and (FHeader.FMainColumn < 0) then
    FHeader.FMainColumn := 0;

  if not (csLoading in FHeader.Treeview.ComponentState) and not (hsLoading in FHeader.FStates) then
  begin
    with FHeader do
    begin
      if hoAutoResize in FOptions then
        AdjustAutoSize(InvalidColumn);
      if Assigned(Item) then
        Invalidate(Item as TVirtualTreeColumn)
      else
        if Treeview.HandleAllocated then
        begin
          Treeview.UpdateHorizontalScrollBar(False);
          Invalidate(nil);
          Treeview.Invalidate;
        end;
      // This is mainly to let the designer know when a change occurs at design time which
      // doesn't involve the object inspector (like column resizing with the mouse).
      // This does NOT include design time code as the comunication is done via an interface.
      Treeview.UpdateDesigner;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumns.UpdatePositions(Force: Boolean = False);

// Recalculates the left border of every column and updates their position property according to the
// PostionToIndex array which primarily determines where each column is placed visually.

var
  I, LeftPos: Integer;

begin
  if Force or (UpdateCount = 0) then
  begin
    LeftPos := 0;
    for I := 0 to High(FPositionToIndex) do
      with Items[FPositionToIndex[I]] do
      begin
        FPosition := I;
        FLeft := LeftPos;
        if coVisible in FOptions then
          Inc(LeftPos, FWidth);
      end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualTreeColumns.Add: TVirtualTreeColumn;

begin
  Result := TVirtualTreeColumn(inherited Add);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumns.Assign(Source: TPersistent);

begin
  // Let the collection class assign the items.
  inherited;

  if Source is TVirtualTreeColumns then
  begin
    // Copying the position array is the only needed task here.
    FPositionToIndex := Copy(TVirtualTreeColumns(Source).FPositionToIndex, 0, MaxInt);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualTreeColumns.ColumnFromPosition(P: TPoint; Relative: Boolean = True): TColumnIndex;

// Determines the current column based on the position passed in P.

var
  I, Sum: Integer;

begin
  Result := InvalidColumn;
  // The position must be within the header area, but we extend the vertical bounds to the entire treeview area.
  if (P.X >= 0) and (P.Y >= 0) and (P.Y <= Integer(FHeader.TreeView.Height)) then
  begin
    if Relative then
      Sum := FHeader.Treeview.FOffsetX
    else
      Sum := 0;
    for I := 0 to Count - 1 do
      if coVisible in Items[FPositionToIndex[I]].FOptions then
      begin
        Inc(Sum, Items[FPositionToIndex[I]].Width);
        if P.X < Sum then
        begin
          Result := FPositionToIndex[I];
          Break;
        end;
      end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualTreeColumns.ColumnFromPosition(PositionIndex: TColumnPosition): TColumnIndex;

// Returns the index of the column at the given position.

begin
  if Integer(PositionIndex) < Length(FPositionToIndex) then
    Result := FPositionToIndex[PositionIndex]
  else
    Result := NoColumn;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumns.FreeTheme;

// Closes any previously opened theme.

begin
  if FHeaderTheme <> 0 then
    CloseThemeData(FHeaderTheme);
  FHeaderTheme := 0;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumns.GetColumnBounds(Column: TColumnIndex; var Left, Right: Integer);

// Returns the left and right bound of the given column. If Column is NoColumn then the entire client width is returned.

begin
  if Column = NoColumn then
  begin
    Left := 0;
    Right := FHeader.Treeview.ClientWidth;
  end
  else
  begin
    Left := Items[Column].Left;
    Right := Left + Items[Column].Width;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualTreeColumns.GetFirstVisibleColumn: TColumnIndex;

// Returns the index of the first visible column or "InvalidColumn" if either no columns are defined or
// all columns are hidden.

var
  I: Integer;

begin
  Result := InvalidColumn;
  for I := 0 to Count - 1 do
    if coVisible in Items[FPositionToIndex[I]].FOptions then
    begin
      Result := FPositionToIndex[I];
      Break;
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualTreeColumns.GetLastVisibleColumn: TColumnIndex;

// Returns the index of the last visible column or "InvalidColumn" if either no columns are defined or
// all columns are hidden.

var
  I: Integer;

begin
  Result := InvalidColumn;
  for I := Count - 1 downto 0 do
    if coVisible in Items[FPositionToIndex[I]].FOptions then
    begin
      Result := FPositionToIndex[I];
      Break;
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualTreeColumns.GetNextColumn(Column: TColumnIndex): TColumnIndex;

// Returns the next column in display order. Column is the index of an item in the collection (a column).

var
  Position: Integer;

begin
  if Column < 0 then
    Result := InvalidColumn
  else
  begin
    Position := Items[Column].Position;
    if Position < Count - 1 then
      Result := FPositionToIndex[Position + 1]
    else
      Result := InvalidColumn;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualTreeColumns.GetNextVisibleColumn(Column: TColumnIndex): TColumnIndex;

// Returns the next visible column in display order, Column is an index into the columns list.

begin
  Result := Column;
  repeat
    Result := GetNextColumn(Result);
  until (Result = InvalidColumn) or (coVisible in Items[Result].FOptions);
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualTreeColumns.GetPreviousColumn(Column: TColumnIndex): TColumnIndex;

// Returns the previous column in display order, Column is an index into the columns list.

var
  Position: Integer;

begin
  if Column < 0 then
    Result := InvalidColumn
  else
  begin
    Position := Items[Column].Position;
    if Position > 0 then
      Result := FPositionToIndex[Position - 1]
    else
      Result := InvalidColumn;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualTreeColumns.GetPreviousVisibleColumn(Column: TColumnIndex): TColumnIndex;

// Returns the previous column in display order, Column is an index into the columns list.

begin
  Result := Column;
  repeat
    Result := GetPreviousColumn(Result);
  until (Result = InvalidColumn) or (coVisible in Items[Result].FOptions);
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualTreeColumns.GetVisibleColumns: TColumnsArray;

// Returns a list of all currently visible columns in actual order.

var
  I, Counter: Integer;

begin
  SetLength(Result, Count);
  Counter := 0;

  for I := 0 to Count - 1 do
    if coVisible in Items[FPositionToIndex[I]].FOptions then
    begin
      Result[Counter] := Items[FPositionToIndex[I]];
      Inc(Counter);
    end;
  // Set result length to actual visible count.
  SetLength(Result, Counter);
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualTreeColumns.IsValidColumn(Column: TColumnIndex): Boolean;

// Determines whether the given column is valid or not, that is, whether it is one of the current columns.

begin
  Result := (Column > NoColumn) and (Column < Count);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumns.LoadFromStream(const Stream: TStream; Version: Integer);

var
  I,
  ItemCount: Integer;

begin
  Clear;
  Stream.ReadBuffer(ItemCount, SizeOf(ItemCount));
  // number of columns
  if ItemCount > 0 then
  begin
    BeginUpdate;
    try
      for I := 0 to ItemCount - 1 do
        Add.LoadFromStream(Stream, Version);
      SetLength(FPositionToIndex, ItemCount);
      Stream.ReadBuffer(FPositionToIndex[0], ItemCount * SizeOf(Cardinal));
      UpdatePositions(True);
    finally
      EndUpdate;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

// XP style header button legacy code. This procedure is only used on non-XP systems to simulate the themed
// header style.

const
  XPMainHeaderColorUp = $DBEAEB;       // Main background color of the header if drawn as being not pressed.
  XPMainHeaderColorDown = $D8DFDE;     // Main background color of the header if drawn as being pressed.
  XPMainHeaderColorHover = $F3F8FA;    // Main background color of the header if drawn as being under the mouse pointer.
  XPDarkSplitBarColor = $B2C5C7;       // Dark color of the splitter bar.
  XPLightSplitBarColor = $FFFFFF;      // Light color of the splitter bar.
  XPDarkGradientColor = $B8C7CB;       // Darkest color in the bottom gradient. Other colors will be interpolated.
  XPDownOuterLineColor = $97A5A5;      // Down state border color.
  XPDownMiddleLineColor = $B8C2C1;     // Down state border color.
  XPDownInnerLineColor = $C9D1D0;      // Down state border color.

procedure DrawXPButton(DC: HDC; ButtonR: TRect; DrawSplitter, Down, Hover: Boolean);

// Helper procedure to draw an Windows XP like header button.

var
  PaintBrush: HBRUSH;
  Pen,
  OldPen: HPEN;
  PenColor,
  FillColor: COLORREF;
  dRed, dGreen, dBlue: Single;
  Width,
  XPos: Integer;

begin
  if Down then
    FillColor := XPMainHeaderColorDown
  else
    if Hover then
      FillColor := XPMainHeaderColorHover
    else
      FillColor := XPMainHeaderColorUp;
  PaintBrush := CreateSolidBrush(FillColor);
  FillRect(DC, ButtonR, PaintBrush);
  DeleteObject(PaintBrush);

  if DrawSplitter and not (Down or Hover) then
  begin
    // One solid pen for the dark line...
    Pen := CreatePen(PS_SOLID, 1, XPDarkSplitBarColor);
    OldPen := SelectObject(DC, Pen);
    MoveToEx(DC, ButtonR.Right - 2, ButtonR.Top + 3, nil);       
    LineTo(DC, ButtonR.Right - 2, ButtonR.Bottom - 5);
    // ... and one solid pen for the light line.
    Pen := CreatePen(PS_SOLID, 1, XPLightSplitBarColor);
    DeleteObject(SelectObject(DC, Pen));
    MoveToEx(DC, ButtonR.Right - 1, ButtonR.Top + 3, nil);
    LineTo(DC, ButtonR.Right - 1, ButtonR.Bottom - 5);
    SelectObject(DC, OldPen);
    DeleteObject(Pen);
  end;

  if Down then
  begin
    // Down state. Three lines to draw.
    // First one is the outer line, drawn at left, bottom and right.
    Pen := CreatePen(PS_SOLID, 1, XPDownOuterLineColor);
    OldPen := SelectObject(DC, Pen);
    MoveToEx(DC, ButtonR.Left, ButtonR.Top, nil);       
    LineTo(DC, ButtonR.Left, ButtonR.Bottom - 1);
    LineTo(DC, ButtonR.Right - 1, ButtonR.Bottom - 1);
    LineTo(DC, ButtonR.Right - 1, ButtonR.Top - 1);

    // Second one is the middle line, which is a bit lighter.
    Pen := CreatePen(PS_SOLID, 1, XPDownMiddleLineColor);
    DeleteObject(SelectObject(DC, Pen));
    MoveToEx(DC, ButtonR.Left + 1, ButtonR.Bottom - 2, nil);
    LineTo(DC, ButtonR.Left + 1, ButtonR.Top);
    LineTo(DC, ButtonR.Right - 1, ButtonR.Top);

    // Third line is the inner line, which is even lighter than the middle line.
    Pen := CreatePen(PS_SOLID, 1, XPDownInnerLineColor);
    DeleteObject(SelectObject(DC, Pen));
    MoveToEx(DC, ButtonR.Left + 2, ButtonR.Bottom - 2, nil);
    LineTo(DC, ButtonR.Left + 2, ButtonR.Top + 1);
    LineTo(DC, ButtonR.Right - 1, ButtonR.Top + 1);

    // Housekeeping:
    SelectObject(DC, OldPen);
    DeleteObject(Pen);
  end
  else
    if Hover then
    begin
      // Hover state. There are three lines at the bottom border, but they are rendered in a way which
      // requires expensive construction. Unless the colors change with the Windows theme those lines will be
      // loaded from the utilities images.
      Width := ButtonR.Right - ButtonR.Left;
      if Width <= 32 then
      begin
        ImageList_DrawEx(UtilityImages.Handle, 8, DC, ButtonR.Right - 16, ButtonR.Bottom - 3, 16, 3, CLR_NONE, CLR_NONE,
          ILD_NORMAL);
        ImageList_DrawEx(UtilityImages.Handle, 6, DC, ButtonR.Left, ButtonR.Bottom - 3, Width div 2, 3, CLR_NONE, CLR_NONE,
          ILD_NORMAL);
      end
      else
      begin
        ImageList_DrawEx(UtilityImages.Handle, 6, DC, ButtonR.Left, ButtonR.Bottom - 3, 16, 3, CLR_NONE, CLR_NONE,
          ILD_NORMAL);
        // Replicate inner part as many times as need to fill up the button rectangle.
        XPos := ButtonR.Left + 16;
        repeat
          ImageList_DrawEx(UtilityImages.Handle, 7, DC, XPos, ButtonR.Bottom - 3, 16, 3, CLR_NONE, CLR_NONE, ILD_NORMAL);
          Inc(XPos, 16);
        until XPos + 16 >= ButtonR.Right;
        ImageList_DrawEx(UtilityImages.Handle, 8, DC, ButtonR.Right - 16, ButtonR.Bottom - 3, 16, 3, CLR_NONE, CLR_NONE,
          ILD_NORMAL);                                 
      end;
    end
    else
    begin
      // There is a three line gradient near the bottom border which transforms from the button color to a dark, clBtnFace
      // like color (here XPDarkGradientColor).
      PenColor := XPMainHeaderColorUp;
      dRed := ((PenColor and $FF) - (XPDarkGradientColor and $FF)) / 3;
      dGreen := (((PenColor shr 8) and $FF) - ((XPDarkGradientColor shr 8) and $FF)) / 3;
      dBlue := (((PenColor shr 16) and $FF) - ((XPDarkGradientColor shr 16) and $FF)) / 3;

      // First line:
      PenColor := PenColor - Round(dRed) - Round(dGreen) shl 8 - Round(dBlue) shl 16;
      Pen := CreatePen(PS_SOLID, 1, PenColor);
      OldPen := SelectObject(DC, Pen);
      MoveToEx(DC, ButtonR.Left, ButtonR.Bottom - 3, nil);
      LineTo(DC, ButtonR.Right, ButtonR.Bottom - 3);

      // Second line:
      PenColor := PenColor - Round(dRed) - Round(dGreen) shl 8 - Round(dBlue) shl 16;
      Pen := CreatePen(PS_SOLID, 1, PenColor);
      DeleteObject(SelectObject(DC, Pen));
      MoveToEx(DC, ButtonR.Left, ButtonR.Bottom - 2, nil);
      LineTo(DC, ButtonR.Right, ButtonR.Bottom - 2);

      // Third line:
      Pen := CreatePen(PS_SOLID, 1, XPDarkGradientColor);
      DeleteObject(SelectObject(DC, Pen));
      MoveToEx(DC, ButtonR.Left, ButtonR.Bottom - 1, nil);
      LineTo(DC, ButtonR.Right, ButtonR.Bottom - 1);

      // Housekeeping:
      DeleteObject(SelectObject(DC, OldPen));
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumns.PaintHeader(DC: HDC; R: TRect; HOffset: Integer);

// Main paint method to draw the header.

const
  SortGlyphs: array[TSortDirection, Boolean] of Integer = ( // ascending/descending, normal/XP style
    (3, 5) {ascending}, (2, 4) {descending}
  );

  // Theme values
  // pressed state, hover state
  HeaderStateID: array[Boolean, Boolean] of Integer = (
    (HIS_NORMAL, HIS_HOT), (HIS_PRESSED, HIS_PRESSED)
  );
  // with or without splitter
  HeaderItem: array[Boolean] of Integer = (
    HP_HEADERITEMLEFT, HP_HEADERITEM
  );

var
  I, Y,
  SortIndex: Integer;
  ButtonR,
  TextR,
  Run: TRect;
  GlyphPos,
  SortGlyphPos: TPoint;
  RightBorderFlag,
  NormalButtonStyle,
  NormalButtonFlags,
  PressedButtonStyle,
  PressedButtonFlags,
  RaisedButtonStyle,
  RaisedButtonFlags: Cardinal;
  DrawFormat: Cardinal;
  Images: TImageList;
  ButtonRgn: HRGN;
  OwnerDraw: Boolean;

  // short hand variables to avoid frequent expensive tests
  IsHoverIndex,
  IsDownIndex,
  IsEnabled,
  ShowHeaderGlyph,
  ShowSortGlyph,
  ShowRightBorder: Boolean;
  DropMark: TVTDropMarkMode;

begin
  ButtonR := FHeader.Treeview.FHeaderRect;
  FHeaderBitmap.Width := Max(ButtonR.Right, R.Right - R.Left);
  FHeaderBitmap.Height := ButtonR.Bottom;
  OwnerDraw := (hoOwnerDraw in FHeader.FOptions) and Assigned(FHeader.Treeview.FOnHeaderDraw) and
    not (csDesigning in FHeader.Treeview.ComponentState);

  with FHeaderBitmap.Canvas do
  begin
    Font := FHeader.FFont;

    RaisedButtonStyle := 0;
    RaisedButtonFlags := 0;
    case FHeader.Style of
      hsThickButtons:
        begin
          NormalButtonStyle := BDR_RAISEDINNER or BDR_RAISEDOUTER;
          NormalButtonFlags := BF_LEFT or BF_TOP or BF_BOTTOM or BF_MIDDLE or BF_SOFT or BF_ADJUST;
          PressedButtonStyle := BDR_RAISEDINNER or BDR_RAISEDOUTER;
          PressedButtonFlags := NormalButtonFlags or BF_RIGHT or BF_FLAT or BF_ADJUST;
        end;
      hsFlatButtons:
        begin
          NormalButtonStyle := BDR_RAISEDINNER;
          NormalButtonFlags := BF_LEFT or BF_TOP or BF_BOTTOM or BF_MIDDLE or BF_ADJUST;
          PressedButtonStyle := BDR_SUNKENOUTER;
          PressedButtonFlags := BF_RECT or BF_MIDDLE or BF_ADJUST;
        end;
    else
      // hsPlates or hsXPStyle, values are not used in the latter case
      begin
        NormalButtonStyle := BDR_RAISEDINNER;
        NormalButtonFlags := BF_RECT or BF_MIDDLE or BF_SOFT or BF_ADJUST;
        PressedButtonStyle := BDR_SUNKENOUTER;
        PressedButtonFlags := BF_RECT or BF_MIDDLE or BF_ADJUST;
        RaisedButtonStyle := BDR_RAISEDINNER;
        RaisedButtonFlags := BF_LEFT or BF_TOP or BF_BOTTOM or BF_MIDDLE or BF_ADJUST;
      end;
    end;

    // use shortcut for the images
    Images := FHeader.FImages;

    Run.Top := R.Top;
    Run.Right := R.Left + HOffset;
    Run.Bottom := R.Bottom;
    // Run.Left is set in the loop

    ShowRightBorder := (FHeader.Style = hsThickButtons) or not (hoAutoResize in FHeader.FOptions) or
      (FHeader.Treeview.BevelKind = bkNone);
    // now go for each button
    for I := 0 to Count - 1 do
      with Items[FPositionToIndex[I]] do
        if coVisible in FOptions then
        begin
          Run.Left := Run.Right;
          Inc(Run.Right, Items[FPositionToIndex[I]].Width);
          // Skip columns which are not visible at all.
          if Run.Right > R.Left then
          begin
            // Stop painting if the rectangle is filled. 
            if Run.Left > R.Right then
              Break;

            IsHoverIndex := (Integer(FPositionToIndex[I]) = FHoverIndex) and (hoHotTrack in FHeader.FOptions) and
              (coEnabled in FOptions);
            IsDownIndex := Integer(FPositionToIndex[I]) = FDownIndex;
            if (coShowDropMark in FOptions) and (Integer(FPositionToIndex[I]) = FDropTarget) and
              (Integer(FPositionToIndex[I]) <> FDragIndex) then
            begin
              if FDropBefore then
                DropMark := dmmLeft
              else
                DropMark := dmmRight;
            end
            else
              DropMark := dmmNone;
            IsEnabled := (coEnabled in FOptions) and (FHeader.Treeview.Enabled);
            ShowHeaderGlyph := (hoShowImages in FHeader.FOptions) and Assigned(Images) and (FImageIndex > -1);
            ShowSortGlyph := (Integer(FPositionToIndex[I]) = FHeader.FSortColumn) and (hoShowSortGlyphs in FHeader.FOptions);

            ButtonR := Run;

            // Draw button edge/divider only if not owner draw.
            if (Style = vsText) or not OwnerDraw then
            begin
              if ShowRightBorder or (I < Count - 1) then
                RightBorderFlag := BF_RIGHT
              else
                RightBorderFlag := 0;

              // Draw button first before setting the clip region.
              if tsUseThemes in FHeader.Treeview.FStates then
              begin
                DrawThemeBackground(FHeaderTheme, Handle, HeaderItem[RightBorderFlag <> 0], HeaderStateID[IsDownIndex,
                  IsHoverIndex], ButtonR, @ButtonR);
              end
              else
              begin
                if FHeader.Style = hsXPStyle then
                  DrawXPButton(Handle, ButtonR, RightBorderFlag <> 0, IsDownIndex, IsHoverIndex)
                else
                  if IsDownIndex then
                    DrawEdge(Handle, ButtonR, PressedButtonStyle, PressedButtonFlags)
                  else
                    // Plates have the special case of raising on mouse over.
                    if (FHeader.Style = hsPlates) and IsHoverIndex and
                      (coAllowClick in FOptions) and (coEnabled in FOptions) then
                      DrawEdge(Handle, ButtonR, RaisedButtonStyle, RaisedButtonFlags or RightBorderFlag)
                    else
                      DrawEdge(Handle, ButtonR, NormalButtonStyle, NormalButtonFlags or RightBorderFlag);
              end;
            end;

            // Create a clip region to avoid overpainting any other area which does not belong to this column.
            if ButtonR.Right > R.Right then
              ButtonR.Right := R.Right;
            if ButtonR.Left < R.Left then
              ButtonR.Left := R.Left;
            ButtonRgn := CreateRectRgnIndirect(ButtonR);
            SelectClipRgn(Handle, ButtonRgn);
            DeleteObject(ButtonRgn);

            ButtonR := Run;
            if (Style = vsText) or not OwnerDraw then
            begin
              // calculate text and glyph position
              InflateRect(ButtonR, -2, -2);
              DrawFormat := DT_LEFT or DT_TOP;
              if UseRightToLeftReading then
                DrawFormat := DrawFormat + DT_RTLREADING;
              ComputeHeaderLayout(Handle, ButtonR, ShowHeaderGlyph, ShowSortGlyph, GlyphPos, SortGlyphPos, TextR);

              // Move glyph and text one pixel to the right and down to simulate a pressed button.
              if IsDownIndex then
              begin
                OffsetRect(TextR, 1, 1);
                Inc(GlyphPos.X);
                Inc(GlyphPos.Y);
                Inc(SortGlyphPos.X);
                Inc(SortGlyphPos.Y);
              end;

              // main glyph
              if ShowHeaderGlyph and
                (not ShowSortGlyph or (FBidiMode <> bdLeftToRight) or (GlyphPos.X + Images.Width <= SortGlyphPos.X)) then
                Images.Draw(FHeaderBitmap.Canvas, GlyphPos.X, GlyphPos.Y, FImageIndex, IsEnabled);

              // caption
              if Length(Text) > 0 then
                DrawButtonText(Handle, Text, TextR, IsEnabled, IsHoverIndex and (hoHotTrack in FHeader.FOptions) and
                not (tsUseThemes in FHeader.Treeview.FStates), DrawFormat);

              // sort glyph                         
              if ShowSortGlyph then
              begin
                // For the time being this does not work. I have no idea how the explorer does the painting
                // but even demo applications from MS don't work.
                {if DrawThemed then
                  DrawThemeBackground(FHeaderTheme, Handle, HP_HEADERSORTARROW, HSAS_SORTEDDOWN,
                    Rect(SortGlyphPos.X, SortGlyphPos.Y, SortGlyphPos.X + 16, SortGlyphPos.Y + 16), nil)
                else}
                begin
                  SortIndex := SortGlyphs[FHeader.FSortDirection, tsUseThemes in FHeader.Treeview.FStates];
                  UtilityImages.Draw(FHeaderBitmap.Canvas, SortGlyphPos.X, SortGlyphPos.Y, SortIndex);
                end;
              end;

              // Show an indication if this column is the current drop target in a header drag operation.
              if DropMark <> dmmNone then
              begin
                Y := (ButtonR.Top + ButtonR.Bottom - UtilityImages.Height) div 2;
                if DropMark = dmmLeft then
                begin
                  with ButtonR do
                    UtilityImages.Draw(FHeaderBitmap.Canvas, Left, Y, 0);
                end
                else
                begin
                  with ButtonR do
                    UtilityImages.Draw(FHeaderBitmap.Canvas, Right - 16 , Y,  1);
                end;
              end;
            end
            else // Let application draw the header.
              FHeader.Treeview.DoHeaderDraw(FHeaderBitmap.Canvas, Items[FPositionToIndex[I]], ButtonR, IsHoverIndex,
                IsDownIndex, DropMark);
            SelectClipRgn(Handle, 0);
          end;
        end;

    if Run.Right < R.Right then
    begin
      ButtonR := R;
      with ButtonR do
        IntersectClipRect(Handle, Run.Right, Top, Right, Bottom);
      // finally erase unused header space
      ButtonR.Left := Run.Right;
      if tsUseThemes in FHeader.Treeview.FStates then
        DrawThemeBackground(FHeaderTheme, Handle, HP_HEADERITEMRIGHT, HIRS_NORMAL, ButtonR, @ButtonR)
      else
        if FHeader.Style = hsXPStyle then
          DrawXPButton(Handle, ButtonR, False, False, False)
        else
        begin
          Brush.Color := FHeader.FBackground;
          FillRect(ButtonR);
        end;
    end;

    // blit the result to target
    with R do
      BitBlt(DC, Left, Top, Right - Left, Bottom - Top, Handle, Left, Top, SRCCOPY);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumns.SaveToStream(const Stream: TStream);

var
  I: Integer;

begin
  I := Count;
  Stream.WriteBuffer(I, SizeOf(I));
  if I > 0 then
  begin
    for I := 0 to Count - 1 do
      TVirtualTreeColumn(Items[I]).SaveToStream(Stream);

    Stream.WriteBuffer(FPositionToIndex[0], Count * SizeOf(Cardinal));
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualTreeColumns.TotalWidth: Integer;

var
  LastColumn: Integer;

begin
  if Count = 0 then
    Result := 0
  else
  begin
    LastColumn := FPositionToIndex[Count - 1];
    if not (coVisible in Items[LastColumn].FOptions) then
      LastColumn := GetPreviousVisibleColumn(LastColumn);
    if LastColumn > NoColumn then
      with Items[LastColumn] do
        Result := FLeft + FWidth
    else
      Result := 0;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualTreeColumns.UpdateTheme(Window: HWND);

// Triggered when the application is themed. Releases any previously opened theme and
// opens the new theme for the header stuff.

begin
  FreeTheme;
  if tsUseThemes in FHeader.Treeview.FStates then
    FHeaderTheme := OpenThemeData(Window, 'header');
end;

//----------------- TVTHeader -----------------------------------------------------------------------------------------

constructor TVTHeader.Create(AOwner: TBaseVirtualTree);

begin
  inherited Create;
  FOwner := AOwner;
  FColumns := TVirtualTreeColumns.Create(Self);
  FHeight := 17;
  FFont := TFont.Create;
  FFont.OnChange := FontChanged;
  FBackground := clBtnFace;
  FOptions := [hoColumnResize, hoDrag];

  FImageChangeLink := TChangeLink.Create;
  FImageChangeLink.OnChange := ImageListChange;

  FSortColumn := NoColumn;
  FSortDirection := sdAscending;
  FMainColumn := NoColumn;

  FDragImage := TVTDragImage.Create(AOwner);
  with FDragImage do
  begin
    Fade := False;
    PostBlendBias := 0;
    PreBlendBias := -50;
    Transparency := 140;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

destructor TVTHeader.Destroy;

begin
  FDragImage.Free;
  FImageChangeLink.Free;
  FFont.Free;
  FColumns.Free;
  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTHeader.DetermineSplitterIndex(P: TPoint): Boolean;

// Tries to find the index of that column whose right border corresponds to P.
// Result is True if column border was hit (with -3..+5 pixels tolerance).
// For continuous resizing the current track index and the column's left border are set.
// Note: The hit test is checking from right to left to make enlarging of zero-sized columns possible.

var
  I,
  SplitPoint: Integer;

begin
  Result := False;
  FColumns.FTrackIndex := NoColumn;

  if FColumns.Count > 0 then
  begin
    SplitPoint := Treeview.FOffsetX + Integer(Treeview.FRangeX);

    for I := FColumns.Count - 1 downto 0 do
      with FColumns, Items[FPositionToIndex[I]] do
        if coVisible in FOptions then
        begin
          if (P.X < SplitPoint + 5) and (P.X > SplitPoint - 3) then
          begin
            if coResizable in FOptions then
            begin
              Result := True;
              FTrackIndex := FPositionToIndex[I];
              FLeftTrackPos := SplitPoint - FWidth;
            end;
            Break;
          end;
          Dec(SplitPoint, FWidth);
        end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTHeader.FontChanged(Sender: TObject);

begin
  Invalidate(nil);
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTHeader.GetShiftState: TShiftState;

begin
  Result := [];
  if GetKeyState(VK_SHIFT) < 0 then Include(Result, ssShift);
  if GetKeyState(VK_CONTROL) < 0 then Include(Result, ssCtrl);
  if GetKeyState(VK_MENU) < 0 then Include(Result, ssAlt);
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTHeader.GetMainColumn: TColumnIndex;

begin
  if FColumns.Count > 0 then
    Result := FMainColumn
  else
    Result := NoColumn;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTHeader.GetUseColumns: Boolean;

begin
  Result := FColumns.Count > 0;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTHeader.SetAutoSizeIndex(Value: TColumnIndex);

begin
  if FAutoSizeIndex <> Value then
  begin
    FAutoSizeIndex := Value;
    if hoAutoResize in FOptions then
      Columns.AdjustAutoSize(InvalidColumn);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTHeader.SetBackground(Value: TColor);

begin
  if FBackground <> Value then
  begin
    FBackground := Value;
    Invalidate(nil);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTHeader.SetColumns(Value: TVirtualTreeColumns);

begin
  FColumns.Assign(Value);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTHeader.SetFont(const Value: TFont);

begin
  FFont.Assign(Value);
  Invalidate(nil);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTHeader.SetHeight(Value: Cardinal);

begin
  if FHeight <> Value then
  begin
    FHeight := Value;
    if not (csLoading in Treeview.ComponentState) then
      RecalculateHeader;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTHeader.SetImages(const Value: TImageList);

begin
  if FImages <> Value then
  begin
    if Assigned(FImages) then
      FImages.UnRegisterChanges(FImageChangeLink);
    FImages := Value;
    if Assigned(FImages) then
      FImages.RegisterChanges(FImageChangeLink);
    if not (csLoading in Treeview.ComponentState) then
      Invalidate(nil);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTHeader.SetMainColumn(Value: TColumnIndex);

begin
  if Value < 0 then
    Value := 0;
  if Value > FColumns.Count - 1 then
    Value := FColumns.Count - 1;
  if Value <> FMainColumn then
  begin
    FMainColumn := Value;
    if not (csLoading in Treeview.ComponentState) then
    begin
      Treeview.MainColumnChanged;
      if not (toExtendedFocus in Treeview.FOptions.FSelectionOptions) then
        Treeview.FocusedColumn := FMainColumn;
      Treeview.Invalidate;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTHeader.SetOptions(Value: TVTHeaderOptions);

var
  ToBeSet,
  ToBeCleared: TVTHeaderOptions;

begin
  ToBeSet := Value - FOptions;
  ToBeCleared := FOptions - Value;
  FOptions := Value;

  if (hoAutoResize in (ToBeSet + ToBeCleared)) and (FColumns.Count > 0) then
  begin
    FColumns.AdjustAutoSize(InvalidColumn);
    if Treeview.HandleAllocated then
    begin
      Treeview.UpdateHorizontalScrollBar(False);
      if hoAutoResize in ToBeSet then
        Treeview.Invalidate;
    end;
  end;

  if not (csLoading in Treeview.ComponentState) and Treeview.HandleAllocated then
  begin
    if hoVisible in (ToBeSet + ToBeCleared) then
      RecalculateHeader;
    Invalidate(nil);
    Treeview.Invalidate;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTHeader.SetSortColumn(Value: TColumnIndex);

begin
  if Value < NoColumn then
    Value := NoColumn;
  if Value > Columns.Count - 1 then
    Value := Columns.Count - 1;
  if FSortColumn <> Value then
  begin
    if FSortColumn > NoColumn then
      Invalidate(Columns[FSortColumn]);
    FSortColumn := Value;
    if FSortColumn > NoColumn then
      Invalidate(Columns[FSortColumn]);
    if (toAutoSort in Treeview.FOptions.FAutoOptions) and (Treeview.FUpdateCount = 0) then
      Treeview.SortTree(FSortColumn, FSortDirection, True);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTHeader.SetSortDirection(const Value: TSortDirection);

begin
  if Value <> FSortDirection then
  begin
    FSortDirection := Value;
    Invalidate(nil);
    if (toAutoSort in Treeview.FOptions.FAutoOptions) and (Treeview.FUpdateCount = 0) then
      Treeview.SortTree(FSortColumn, FSortDirection, True);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTHeader.SetStyle(Value: TVTHeaderStyle);

begin
  if FStyle <> Value then
  begin
    FStyle := Value;
    if not (csLoading in Treeview.ComponentState) then
      Invalidate(nil);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTHeader.DragTo(P: TPoint);

// Moves the drag image to a new position, which is determined from the passed point P and the previous
// mouse position.

var
  I,
  NewTarget: Integer;
  // optimized drag image move support
  ClientP: TPoint;
  Left,
  Right: Integer;
  NeedRepaint: Boolean; // True if the screen needs an update (changed drop target or drop side)

begin
  // Determine new drop target and which side of it is prefered.
  ClientP := Treeview.ScreenToClient(P);
  // Make coordinates relative to (0, 0) of the non-client area.
  Inc(ClientP.Y, FHeight);
  NewTarget := FColumns.ColumnFromPosition(ClientP);
  NeedRepaint := (NewTarget <> InvalidColumn) and (NewTarget <> FColumns.FDropTarget);
  if NewTarget >= 0 then
  begin
    FColumns.GetColumnBounds(NewTarget, Left, Right);
    if (ClientP.X < ((Left + Right) div 2)) <> FColumns.FDropBefore then
    begin
      NeedRepaint := True;
      FColumns.FDropBefore := not FColumns.FDropBefore;
    end;
  end;

  if NeedRepaint then
  begin
    // Invalidate columns which need a repaint.
    if FColumns.FDropTarget > NoColumn then
    begin
      I := FColumns.FDropTarget;
      FColumns.FDropTarget := NoColumn;
      Invalidate(FColumns.Items[I]);
    end;
    if (NewTarget > NoColumn) and (NewTarget <> FColumns.FDropTarget) then
    begin
      Invalidate(FColumns.Items[NewTarget]);
      FColumns.FDropTarget := NewTarget;
    end;
  end;

  FDragImage.DragTo(P, NeedRepaint);
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTHeader.GetOwner: TPersistent;

begin
  Result := FOwner;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTHeader.HandleHeaderMouseMove(var Message: TWMMouseMove): Boolean;

var
  P: TPoint;
  I: Integer;
  
begin
  Result := False;
  with Message do
  begin
    P := Point(XPos, YPos);
    if hsTrackPending in FStates then
    begin
      Treeview.StopTimer(HeaderTimer);
      FStates := FStates - [hsTrackPending] + [hsTracking];
      HandleHeaderMouseMove := True;
      Result := 0;
    end
    else
      if hsTracking in FStates then
      begin
        FColumns[FColumns.FTrackIndex].Width := XPos - FLeftTrackPos;
        HandleHeaderMouseMove := True;
        Result := 0;
      end
      else
      begin
        if hsDragPending in FStates then
        begin
          P := Treeview.ClientToScreen(P);
          // start actual dragging if allowed
          if (hoDrag in FOptions) and Treeview.DoHeaderDragging(FColumns.FDownIndex) then
          begin
            if ((Abs(FDragStart.X - P.X) > Mouse.DragThreshold) or
               (Abs(FDragStart.Y - P.Y) > Mouse.DragThreshold)) then
            begin
              Treeview.StopTimer(HeaderTimer);
              I := FColumns.FDownIndex;
              FColumns.FDownIndex := NoColumn;
              FColumns.FHoverIndex := NoColumn;
              if I > NoColumn then
                Invalidate(FColumns[I]);
              PrepareDrag(P, FDragStart);
              FStates := FStates - [hsDragPending] + [hsDragging];
              HandleHeaderMouseMove := True;
              Result := 0;
            end;
          end;
        end
        else
          if hsDragging in FStates then
          begin
            DragTo(Treeview.ClientToScreen(Point(XPos, YPos)));
            HandleHeaderMouseMove := True;
            Result := 0;
          end;
      end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTHeader.HandleMessage(var Message: TMessage): Boolean;

// The header gets here the opportunity to handle certain messages before they reach the tree. This is important
// because the tree needs to handle various non-client area messages for the header as well as some dragging/tracking
// events.
// By returning True the message will not be handled further, otherwise the tree is then dispatched
// to the proper message handlers.

var
  P: TPoint;
  R: TRect;
  I: Integer;
  OldPosition: Integer;
  HitIndex: TColumnIndex;
  NewCursor: HCURSOR;
  Button: TMouseButton;
  
begin
  Result := False;
  case Message.Msg of
    WM_SIZE:
      begin
        if (hoAutoResize in FOptions) and not (hsAutoSizing in FStates) and
          not (tsWindowCreating in FOwner.FStates) then
        begin
          FColumns.AdjustAutoSize(InvalidColumn);
          Invalidate(nil);
        end;
      end;
    CM_BIDIMODECHANGED:
      for I := 0 to FColumns.Count - 1 do
        if coParentBiDiMode in FColumns[I].FOptions then
          FColumns[I].ParentBiDiModeChanged;
    WM_NCMBUTTONDOWN:
      begin
        with TWMNCMButtonDown(Message) do
          P := Treeview.ScreenToClient(Point(XCursor, YCursor));
        if InHeader(P) then
          FOwner.DoHeaderMouseDown(mbMiddle, GetShiftState, P.X, P.Y + Integer(FHeight));
      end;
    WM_NCMBUTTONUP:
      begin
        with TWMNCMButtonUp(Message) do
          P := FOwner.ScreenToClient(Point(XCursor, YCursor));
        if InHeader(P) then
        begin
          FColumns.HandleClick(P, mbMiddle, True);
          FOwner.DoHeaderMouseUp(mbMiddle, GetShiftState, P.X, P.Y + Integer(FHeight));
          FColumns.FDownIndex := NoColumn;
        end;
      end;
    WM_NCLBUTTONDBLCLK,
    WM_NCMBUTTONDBLCLK,
    WM_NCRBUTTONDBLCLK:
      begin
        with TWMNCLButtonDblClk(Message) do
          P := FOwner.ScreenToClient(Point(XCursor, YCursor));
        // If the click was on a splitter then resize column do smallest width.
        if InHeader(P) then
        begin
          case Message.Msg of
            WM_NCMBUTTONDBLCLK:
              Button := mbMiddle;
            WM_NCRBUTTONDBLCLK:
              Button := mbRight;
          else
            // WM_NCLBUTTONDBLCLK
            Button := mbLeft;
          end;
          if (hoDblClickResize in FOptions) and (FColumns.FTrackIndex > NoColumn) then
          begin
            with FColumns do
              AnimatedResize(FTrackIndex, Max(FColumns[FTrackIndex].MinWidth, Treeview.GetMaxColumnWidth(FTrackIndex)));
          end
          else
            FColumns.HandleClick(P, Button, True);
          FOwner.DoHeaderDblClick(FColumns.FClickIndex, Button, GetShiftState, P.X, P.Y + Integer(FHeight));
        end;
      end;
    WM_NCLBUTTONDOWN:
      begin
        Application.CancelHint;

        // make sure no auto scrolling is active...
        Treeview.StopTimer(ScrollTimer);
        Treeview.FStates := Treeview.FStates - [tsScrollPending, tsScrolling];
        // ... pending editing is cancelled (actual editing remains active)
        Treeview.StopTimer(EditTimer);
        Exclude(Treeview.FStates, tsEditPending);

        with TWMNCLButtonDown(Message) do
        begin
          // want the drag start point in screen coordinates
          FDragStart := Point(XCursor, YCursor);
          P := Treeview.ScreenToClient(FDragStart);
        end;

        if InHeader(P) then
        begin
          // This is a good opportunity to notify the application.
          FOwner.DoHeaderMouseDown(mbLeft, GetShiftState, P.X, P.Y + Integer(FHeight));

          if DetermineSplitterIndex(P) and (hoColumnResize in FOptions) then
          begin
            FColumns.FHoverIndex := NoColumn;
            FTrackStart := P;
            Include(FStates, hsTrackPending);
            SetCapture(Treeview.Handle);
            Result := True;
            Message.Result := 0;
          end
          else
          begin
            HitIndex := Columns.AdjustDownColumn(P);
            if (hoDrag in FOptions) and (HitIndex > NoColumn) and (coDraggable in FColumns[HitIndex].FOptions) then
            begin
              // Show potential drag operation.
              // Disabled columns do not start a drag operation because they can't be clicked.
              Include(FStates, hsDragPending);
              SetCapture(Treeview.Handle);
              Result := True;
              Message.Result := 0;
            end;
          end;
        end;
      end;
    WM_NCRBUTTONDOWN:
      begin
        with TWMNCRButtonDown(Message) do
          P := FOwner.ScreenToClient(Point(XCursor, YCursor));
        if InHeader(P) then
          FOwner.DoHeaderMouseDown(mbRight, GetShiftState, P.X, P.Y + Integer(FHeight));
      end;
    WM_NCRBUTTONUP:
      if not (csDesigning in FOwner.ComponentState) then
        with TWMNCRButtonUp(Message) do
        begin
          Application.CancelHint;

          P := FOwner.ScreenToClient(Point(XCursor, YCursor));
          if InHeader(P) then
          begin
            FColumns.HandleClick(P, mbRight, True);
            FOwner.DoHeaderMouseUp(mbRight, GetShiftState, P.X, P.Y + Integer(FHeight));
            FColumns.FDownIndex := NoColumn;
            FColumns.FTrackIndex := NoColumn;

            // Trigger header popup if there's one.
            if Assigned(FPopupMenu) then
            begin
              Treeview.StopTimer(ScrollTimer);
              Treeview.StopTimer(HeaderTimer);
              FColumns.FHoverIndex := NoColumn;
              Treeview.FStates := Treeview.FStates - [tsScrollPending, tsScrolling];
              FPopupMenu.PopupComponent := Treeview;
              FPopupMenu.Popup(XCursor, YCursor);
              HandleMessage := True;
            end;
          end;
        end;
    // When the tree window has an active mouse capture then we only get "client-area" messages.
    WM_LBUTTONUP,
    WM_NCLBUTTONUP:
      begin
        Application.CancelHint;

        if FStates <> [] then
        begin
          ReleaseCapture;
          if hsDragging in FStates then
          begin
            // successfull dragging moves columns
            with TWMLButtonUp(Message) do
              P := Treeview.ClientToScreen(Point(XPos, YPos));
            GetWindowRect(Treeview.Handle, R);
            with FColumns do
            begin
              FDragImage.EndDrag;
              if (FDropTarget > -1) and (FDropTarget <> FDragIndex) and PtInRect(R, P) then
              begin
                OldPosition := FColumns[FDragIndex].Position;
                if FColumns.FDropBefore then
                begin
                  if FColumns[FDragIndex].Position < FColumns[FDropTarget].Position then
                    FColumns[FDragIndex].Position := Max(0, FColumns[FDropTarget].Position - 1)
                  else
                    FColumns[FDragIndex].Position := FColumns[FDropTarget].Position;
                end
                else
                begin
                  if FColumns[FDragIndex].Position < FColumns[FDropTarget].Position then
                    FColumns[FDragIndex].Position := FColumns[FDropTarget].Position
                  else
                    FColumns[FDragIndex].Position := FColumns[FDropTarget].Position + 1;
                end;
                Self.Treeview.DoHeaderDragged(FDragIndex, OldPosition);
              end;
              FDropTarget := NoColumn;
            end;
            Invalidate(nil);
          end;
          Result := True;
          Message.Result := 0;
        end;

        case Message.Msg of
          WM_LBUTTONUP:
            with TWMLButtonUp(Message) do
            begin
              if FColumns.FDownIndex > NoColumn then
                FColumns.HandleClick(Point(XPos, YPos), mbLeft, False);
              if FStates <> [] then
                FOwner.DoHeaderMouseUp(mbLeft, KeysToShiftState(Keys), XPos, YPos);
            end;
          WM_NCLBUTTONUP:
            with TWMNCLButtonUp(Message) do
            begin
              P := FOwner.ScreenToClient(Point(XCursor, YCursor));
              FColumns.HandleClick(P, mbLeft, False);
              FOwner.DoHeaderMouseUp(mbLeft, GetShiftState, P.X, P.Y + Integer(FHeight));
            end;
        end;

        if FColumns.FTrackIndex > NoColumn then
        begin
          Invalidate(Columns[FColumns.FTrackIndex]);
          FColumns.FTrackIndex := NoColumn;
        end;
        if FColumns.FDownIndex > NoColumn then
        begin
          Invalidate(Columns[FColumns.FDownIndex]);
          FColumns.FDownIndex := NoColumn;
        end;
        FStates := FStates - [hsDragging, hsDragPending, hsTracking, hsTrackPending];
      end;
    // hovering, mouse leave detection
    WM_NCMOUSEMOVE:
      with TWMNCMouseMove(Message), FColumns do
      begin
        P := Treeview.ScreenToClient(Point(XCursor, YCursor));
        Treeview.DoHeaderMouseMove(GetShiftState, P.X, P.Y + Integer(FHeight));
        if InHeader(P) and ((AdjustHoverColumn(P)) or ((FDownIndex >= 0) and (FHoverIndex <> FDownIndex))) then
        begin
          // We need a mouse leave detection from here for the non client area. The best solution available would be the
          // TrackMouseEvent API. Unfortunately, it leaves Win95 totally and WinNT4 for non-client stuff out and
          // currently I cannot ignore these systems. Hence I go the only other reliable way and use a timer
          // (although, I don't like it...).
          Treeview.StopTimer(HeaderTimer);
          SetTimer(Treeview.Handle, HeaderTimer, 50, nil);
          // use Delphi's internal hint handling for header hints too
          if hoShowHint in FOptions then
          begin
            // client coordinates!
            XCursor := P.x;
            YCursor := P.y + Integer(FHeight);
            Application.HintMouseMessage(Treeview, Message);
          end;
        end
      end;
    WM_TIMER:
      if TWMTimer(Message).TimerID = HeaderTimer then
      begin
        // determine current mouse position to check if it left the window
        GetCursorPos(P);
        P := Treeview.ScreenToClient(P);
        with FColumns do
        begin
          if not InHeader(P) or ((FDownIndex > NoColumn) and (FHoverIndex <> FDownIndex)) then
          begin
            Treeview.StopTimer(HeaderTimer);
            FHoverIndex := NoColumn;
            FClickIndex := NoColumn;
            FDownIndex := NoColumn;
            Result := True;
            Message.Result := 0;
            Invalidate(nil);
          end;
        end;
      end;
    WM_MOUSEMOVE: // mouse capture and general message redirection
      Result := HandleHeaderMouseMove(TWMMouseMove(Message));
    WM_SETCURSOR:
      if FStates = [] then
      begin
        // Retrieve last cursor position (GetMessagePos does not work here, I don't know why).
        GetCursorPos(P);
        // Is the mouse in the header rectangle?
        P := Treeview.ScreenToClient(P);
        if InHeader(P) then
        begin
          NewCursor := Screen.Cursors[crDefault];
          if hoColumnResize in FOptions then
          begin
            if DetermineSplitterIndex(P) then
              NewCursor := Screen.Cursors[crHSplit];

            Treeview.DoGetHeaderCursor(NewCursor);
            Result := NewCursor <> Screen.Cursors[crDefault];
            if Result then
            begin
              Windows.SetCursor(NewCursor);
              Message.Result := 1;
            end
          end;
        end;
      end
      else
      begin
        Message.Result := 1;
        Result := True;
      end;
    WM_KEYDOWN,
    WM_KILLFOCUS:
      if (Message.Msg = WM_KILLFOCUS) or
         (TWMKeyDown(Message).CharCode = VK_ESCAPE) then
      begin
        if hsDragging in FStates then
        begin
          ReleaseCapture;
          FDragImage.EndDrag;
          Exclude(FStates, hsDragging);
          FColumns.FDropTarget := NoColumn;
          Invalidate(nil);
          Result := True;
          Message.Result := 0;
        end
        else
          if hsTracking in FStates then
          begin
            ReleaseCapture;
            Exclude(FStates, hsTracking);
            Result := True;
            Message.Result := 0;
          end;
      end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTHeader.ImageListChange(Sender: TObject);

begin
  if not (csDestroying in Treeview.ComponentState) then
    Invalidate(nil);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTHeader.Invalidate(Column: TVirtualTreeColumn; ExpandToRight: Boolean = False);

// Because the header is in the non-client area of the tree it needs some special handling in order to initiate its
// repainting.
// If ExpandToRight is True then not only the given column but everything to its right will be invalidated (useful for
// resizing). This makes only sense when a column is given.

var
  R, RW: TRect;

begin
  if (hoVisible in FOptions) and Treeview.HandleAllocated then
  begin
    if Column = nil then
      R := Treeview.FHeaderRect
    else
    begin
      R := Column.GetRect;
      OffsetRect(R, Treeview.FOffsetX, 0);
      if ExpandToRight then
        R.Right := Treeview.FHeaderRect.Right;
    end;

    // Current position of the owner in screen coordinates.
    GetWindowRect(Treeview.Handle, RW);
    // Consider the header within this rectangle.
    OffsetRect(R, RW.Left, RW.Top);
    // Expressed in client coordinates (because RedrawWindow wants them so, they will actually become negative).
    MapWindowPoints(0, Treeview.Handle, R, 2);
    RedrawWindow(Treeview.Handle, @R, 0, RDW_FRAME or RDW_INVALIDATE or RDW_NOERASE or RDW_NOCHILDREN);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTHeader.PrepareDrag(P, Start: TPoint);

// Initializes dragging of the header, P is the current mouse postion and Start the initial mouse position.

var
  ColumnR,
  HeaderR: TRect;
  Image: TBitmap;
  ImagePos: TPoint;

begin
  // Determine initial position of drag image (screen coordinates).
  FColumns.FDropTarget := NoColumn;
  Start := Treeview.ScreenToClient(Start);
  Inc(Start.Y, FHeight);
  FColumns.FDragIndex := FColumns.ColumnFromPosition(Start);
  ColumnR := FColumns[FColumns.FDragIndex].GetRect;

  HeaderR := Treeview.FHeaderRect;
  // Set right border of the header rectangle to the maximum extent.
  HeaderR.Right := FColumns.TotalWidth;

  // Take out influence of border since we need a seamless drag image.
  OffsetRect(ColumnR, -HeaderR.Left + Treeview.FOffsetX, -HeaderR.Top);

  Image := TBitmap.Create;
  with Image do
  try
    PixelFormat := pf32Bit;
    Width := ColumnR.Right - ColumnR.Left + HeaderR.Left;
    Height := ColumnR.Bottom - ColumnR.Top + HeaderR.Top;

    HeaderR.Left := 0;
    HeaderR.Top := 0;

    // Erase the entire image with the color key value, for the case not everything
    // in the image is covered by the header image.
    Canvas.Brush.Color := clBtnFace;
    Canvas.FillRect(Rect(0, 0, Width, Height));

    FColumns.PaintHeader(Canvas.Handle, HeaderR, -ColumnR.Left + Treeview.FOffsetX);

    ImagePos := Treeview.ClientToScreen(ColumnR.TopLeft);
    // Column rectangles are given in local window coordinates not client coordinates.
    Dec(ImagePos.Y, FHeight);

    if hoRestrictDrag in FOptions then
      FDragImage.MoveRestriction := dmrHorizontalOnly
    else
      FDragImage.MoveRestriction := dmrNone;
    FDragImage.PrepareDrag(Image, ImagePos, P, nil);
    FDragImage.ShowDragImage;
  finally
    Image.Free;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTHeader.RecalculateHeader;

// Initiate a recalculation of the non-client area of the owner tree.

begin
  if Treeview.HandleAllocated then
  begin
    Treeview.UpdateHeaderRect;
    SetWindowPos(Treeview.Handle, 0, 0, 0, 0, 0, SWP_FRAMECHANGED or SWP_NOMOVE or SWP_NOACTIVATE or SWP_NOOWNERZORDER or
      SWP_NOSENDCHANGING or SWP_NOSIZE or SWP_NOZORDER);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTHeader.Assign(Source: TPersistent);

begin
  if Source is TVTHeader then
  begin
    AutoSizeIndex := TVTHeader(Source).AutoSizeIndex;
    Background := TVTHeader(Source).Background;
    Columns := TVTHeader(Source).Columns;
    Font := TVTHeader(Source).Font;
    Height := TVTHeader(Source).Height;
    Options := TVTHeader(Source).Options;
    PopupMenu := TVTHeader(Source).PopupMenu;
    Style := TVTHeader(Source).Style;
  end
  else
    inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTHeader.AutoFitColumns;

var
  I: Integer;
  
begin
  with FColumns do
    for I := 0 to Count - 1 do
      if [coResizable, coVisible] * Items[FPositionToIndex[I]].FOptions = [coResizable, coVisible] then
        AnimatedResize(FPositionToIndex[I], Treeview.GetMaxColumnWidth(FPositionToIndex[I]))
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTHeader.InHeader(P: TPoint): Boolean;

// Determines whether the given point (client coordinates!) is within the header rectangle (non-client coordinates).

var
  R, RW: TRect;

begin
  R := Treeview.FHeaderRect;
  // current position of the owner in screen coordinates
  GetWindowRect(Treeview.Handle, RW);
  // convert to client coordinates
  MapWindowPoints(0, Treeview.Handle, RW, 2);
  // consider the header within this rectangle
  OffsetRect(R, RW.Left, RW.Top);
  Result := PtInRect(R, P);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTHeader.LoadFromStream(const Stream: TStream);

// restore the state of the header from the given stream

var
  Dummy,
  Version: Integer;
  S: string;
  OldOptions: TVTHeaderOptions;

begin
  Include(FStates, hsLoading);
  with Stream do
  try
    // switch off all options which could influence loading the columns (they will be later set again)
    OldOptions := FOptions;
    FOptions := [];

    // determine whether the stream contains data without a version number
    ReadBuffer(Dummy, SizeOf(Dummy));
    if Dummy > -1 then
    begin
      // seek back to undo read operation if this is an old stream format
      Seek(-SizeOf(Dummy), soFromCurrent);
      Version := -1;
    end
    else // read version number if this is a "versionized" format
      ReadBuffer(Version, SizeOf(Version));
    Columns.LoadFromStream(Stream, Version);

    ReadBuffer(Dummy, SizeOf(Dummy));
    AutoSizeIndex := Dummy;
    ReadBuffer(Dummy, SizeOf(Dummy));
    Background := Dummy;
    ReadBuffer(Dummy, SizeOf(Dummy));
    Height := Dummy;
    ReadBuffer(Dummy, SizeOf(Dummy));
    FOptions := OldOptions;
    Options := TVTHeaderOptions(Word(Dummy));
    // PopupMenu is neither saved nor restored
    ReadBuffer(Dummy, SizeOf(Dummy));
    Style := TVTHeaderStyle(Dummy);
    // TFont has no own save routine so we do it manually
    with Font do
    begin
      ReadBuffer(Dummy, SizeOf(Dummy));
      Color := Dummy;
      ReadBuffer(Dummy, SizeOf(Dummy));
      Height := Dummy;
      ReadBuffer(Dummy, SizeOf(Dummy));
      SetLength(S, Dummy);
      ReadBuffer(PChar(S)^, Dummy);
      Name := S;
      ReadBuffer(Dummy, SizeOf(Dummy));
      Pitch := TFontPitch(Dummy);
      ReadBuffer(Dummy, SizeOf(Dummy));
      Style := TFontStyles(Byte(Dummy));
    end;

    // read data introduced by stream version 1+
    if Version > 0 then
    begin
      ReadBuffer(Dummy, SizeOf(Dummy));
      MainColumn := Dummy;
      ReadBuffer(Dummy, SizeOf(Dummy));
      SortColumn := Dummy;
      ReadBuffer(Dummy, SizeOf(Dummy));
      SortDirection := TSortDirection(Byte(Dummy));
    end;
  finally
    Exclude(FStates, hsLoading);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTHeader.RestoreColumns;

// Restores all columns to their width which they had before they have been auto fitted.

var
  I: Integer;

begin
  with FColumns do
    for I := Count - 1 downto 0 do
      if [coResizable, coVisible] * Items[FPositionToIndex[I]].FOptions = [coResizable, coVisible] then
        Items[I].RestoreLastWidth;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTHeader.SaveToStream(const Stream: TStream);

// Saves the complete state of the header into the provided stream.

var
  Dummy: Integer;

begin
  with Stream do
  begin
    // In previous version of VT was no header stream version defined.
    // For feature enhancements it is necessary, however, to know which stream
    // format we are trying to load.
    // In order to distict from non-version streams an indicator is inserted.
    Dummy := -1;
    WriteBuffer(Dummy, SizeOf(Dummy));
    // Write current stream version number, nothing more is required at the time being.
    Dummy := VTHeaderStreamVersion;
    WriteBuffer(Dummy, SizeOf(Dummy));

    // Save columns in case they depend on certain options (like auto size).
    Columns.SaveToStream(Stream);

    Dummy := FAutoSizeIndex;
    WriteBuffer(Dummy, SizeOf(Dummy));
    Dummy := FBackground;
    WriteBuffer(Dummy, SizeOf(Dummy));
    Dummy := FHeight;
    WriteBuffer(Dummy, SizeOf(Dummy));
    Dummy := Word(FOptions);
    WriteBuffer(Dummy, SizeOf(Dummy));
    // PopupMenu is neither saved nor restored
    Dummy := Ord(FStyle);
    WriteBuffer(Dummy, SizeOf(Dummy));
    // TFont has no own save routine so we do it manually
    with Font do
    begin
      Dummy := Color;
      WriteBuffer(Dummy, SizeOf(Dummy));
      Dummy := Height;
      WriteBuffer(Dummy, SizeOf(Dummy));
      Dummy := Length(Name);
      WriteBuffer(Dummy, SizeOf(Dummy));
      WriteBuffer(PChar(Name)^, Dummy);
      Dummy := Ord(Pitch);
      WriteBuffer(Dummy, SizeOf(Dummy));
      // need only to write one: size or height, I decided to write height
      Dummy := Byte(Style);
      WriteBuffer(Dummy, SizeOf(Dummy));
    end;

    // data introduced by stream version 1
    Dummy := FMainColumn;
    WriteBuffer(Dummy, SizeOf(Dummy));
    Dummy := FSortColumn;
    WriteBuffer(Dummy, SizeOf(Dummy));
    Dummy := Byte(FSortDirection);
    WriteBuffer(Dummy, SizeOf(Dummy));
  end;
end;

//----------------- TScrollBarOptions ----------------------------------------------------------------------------------

constructor TScrollBarOptions.Create(AOwner: TBaseVirtualTree);

begin
  inherited Create;

  FOwner := AOwner;
  FAlwaysVisible := False;
  FScrollBarStyle := sbmRegular;
  FScrollBars := ssBoth;
  FIncrementX := 20;
  FIncrementY := 20;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TScrollBarOptions.SetAlwaysVisible(Value: Boolean);

begin
  if FAlwaysVisible <> Value then
  begin
    FAlwaysVisible := Value;
    if not (csLoading in FOwner.ComponentState) and FOwner.HandleAllocated then
      FOwner.RecreateWnd;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TScrollBarOptions.SetScrollBars(Value: TScrollStyle);

begin
  if FScrollbars <> Value then
  begin
    FScrollBars := Value;
    if not (csLoading in FOwner.ComponentState) and FOwner.HandleAllocated then
      FOwner.RecreateWnd;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TScrollBarOptions.SetScrollBarStyle(Value: TScrollBarStyle);

begin
  {$ifndef UseFlatScrollbars}
    Assert(Value = sbmRegular, 'Flat scrollbars styles are disabled. Enable UseFlatScrollbars in VirtualTrees.pas for' +
      'flat scrollbar support.');
  {$endif UseFlatScrollbars}

  if FScrollBarStyle <> Value then
  begin
    FScrollBarStyle := Value;
    {$ifdef UseFlatScrollbars}
      if FOwner.HandleAllocated then
      begin
        // If set to regular style then don't use the emulation mode of the FlatSB APIs but the original APIs.
        // This is necessary because the FlatSB APIs don't respect NC paint request with limited update region
        // (which is necessary for the transparent drag image).
        FOwner.RecreateWnd;
      end;
    {$endif UseFlatScrollbars}
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TScrollBarOptions.GetOwner: TPersistent;

begin
  Result := FOwner;
end;

//----------------- TVTColors ------------------------------------------------------------------------------------------

constructor TVTColors.Create(AOwner: TBaseVirtualTree);

begin
  FOwner := AOwner;
  FColors[0] := clBtnShadow;      // DisabledColor
  FColors[1] := clHighlight;      // DropMarkColor
  FColors[2] := clHighLight;      // DropTargetColor
  FColors[3] := clHighLight;      // FocusedSelectionColor
  FColors[4] := clBtnFace;        // GridLineColor
  FColors[5] := clBtnShadow;      // TreeLineColor
  FColors[6] := clBtnFace;        // UnfocusedSelectionColor
  FColors[7] := clBtnFace;        // BorderColor   
  FColors[8] := clWindowText;     // HotColor
  FColors[9] := clHighLight;      // FocusedSelectionBorderColor
  FColors[10] := clBtnFace;       // UnfocusedSelectionBorderColor
  FColors[11] := clHighlight;     // DropTargetBorderColor
  FColors[12] := clHighlight;     // SelectionRectangleBlendColor
  FColors[13] := clHighlight;     // SelectionRectangleBorderColor
end;

//----------------------------------------------------------------------------------------------------------------------

function TVTColors.GetColor(const Index: Integer): TColor;

begin
  Result := FColors[Index];
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTColors.SetColor(const Index: Integer; const Value: TColor);

begin
  if FColors[Index] <> Value then
  begin
    FColors[Index] := Value;
    // Cause helper bitmap rebuild for grid and tree line colors.
    if not (csLoading in FOwner.ComponentState) and FOwner.HandleAllocated then
    begin
      FOwner.Invalidate;
      if Index = 7 then
        RedrawWindow(FOwner.Handle, nil, 0, RDW_FRAME or RDW_INVALIDATE or RDW_NOERASE or RDW_NOCHILDREN);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTColors.Assign(Source: TPersistent);

begin
  if Source is TVTColors then
  begin
    FColors := TVTColors(Source).FColors;
    if FOwner.FUpdateCount = 0 then
      FOwner.Invalidate;
  end
  else
    inherited;
end;

//----------------- TClipboardFormats ----------------------------------------------------------------------------------

constructor TClipboardFormats.Create(AOwner: TBaseVirtualTree);

begin
  FOwner := AOwner;
  Sorted := True;
  Duplicates := dupIgnore;
end;

//----------------------------------------------------------------------------------------------------------------------

function TClipboardFormats.Add(const S: string): Integer;

// Restrict additions to the clipbard formats to only those which are registered with the owner tree or one of its
// ancestors.

var
  Format: Word;
  RegisteredClass: TVirtualTreeClass;

begin
  RegisteredClass := InternalClipboardFormats.FindFormat(S, Format);
  if Assigned(RegisteredClass) and FOwner.ClassType.InheritsFrom(RegisteredClass) then
    Result := inherited Add(S)
  else
    Result := -1;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TClipboardFormats.Insert(Index: Integer; const S: string);

// Restrict additions to the clipbard formats to only those which are registered with the owner tree or one of its
// ancestors.

var
  Format: Word;
  RegisteredClass: TVirtualTreeClass;

begin
  RegisteredClass := InternalClipboardFormats.FindFormat(S, Format);
  if Assigned(RegisteredClass) and FOwner.ClassType.InheritsFrom(RegisteredClass) then
    inherited Insert(Index, S);
end;

//----------------- TBaseVirtualTree -----------------------------------------------------------------------------------

constructor TBaseVirtualTree.Create(AOwner: TComponent);

begin
  inherited;

  ControlStyle := ControlStyle - [csSetCaption] + [csCaptureMouse, csOpaque, csReplicatable, csDisplayDragImage,
    csReflector];
  FTotalInternalDataSize := 0;
  FNodeDataSize := -1;
  Width := 200;
  Height := 100;
  TabStop := True;
  ParentColor := False;
  FDefaultNodeHeight := 18;
  FDragOperations := [doCopy, doMove];
  FHotCursor := crDefault;
  FScrollBarOptions := TScrollBarOptions.Create(Self);
  FFocusedColumn := NoColumn;
  FDragImageKind := diComplete;
  FLastSelectionLevel := -1;

  FIndent := 18;

  FPlusBM := TBitmap.Create;
  FMinusBM := TBitmap.Create;

  FBorderStyle := bsSingle;
  FButtonStyle := bsRectangle;
  FButtonFillMode := fmTreeColor;

  FHeader := GetHeaderClass.Create(Self);

  // we have an own double buffer handling
  DoubleBuffered := False;

  FCheckImageKind := ckLightCheck;
  FCheckImages := LightCheckImages;

  FImageChangeLink := TChangeLink.Create;
  FImageChangeLink.OnChange := ImageListChange;
  FStateChangeLink := TChangeLink.Create;
  FStateChangeLink.OnChange := ImageListChange;
  FCustomCheckChangeLink := TChangeLink.Create;
  FCustomCheckChangeLink.OnChange := ImageListChange;

  FAutoExpandDelay := 1000;
  FAutoScrollDelay := 1000;
  FAutoScrollInterval := 1;

  FBackground := TPicture.Create;

  FDefaultPasteMode := amAddChildLast;
  FMargin := 4;
  FTextMargin := 4;
  FDragType := dtOLE;
  FDragHeight := 350;
  FDragWidth := 200;

  FColors := TVTColors.Create(Self);
  FEditDelay := 1000;
  
  FDragImage := TVTDragImage.Create(Self);
  with FDragImage do
  begin
    Fade := True;
    PostBlendBias := 0;
    PreBlendBias := 0;
    Transparency := 200;
  end;

  SetLength(FSingletonNodeArray, 1);
  FAnimationDuration := 200;
  FSearchTimeout := 1000;
  FSearchStart := ssFocusedNode;
  FNodeAlignment := naProportional;
  FLineStyle := lsDotted;
  FIncrementalSearch := isNone;
  FClipboardFormats := TClipboardFormats.Create(Self);
  FOptions := GetOptionsClass.Create(Self);

  AddThreadReference;
end;

//----------------------------------------------------------------------------------------------------------------------

destructor TBaseVirtualTree.Destroy;

begin
  InterruptValidation;
  StopWheelPanning;
  CancelEditNode;
  FOptions.Free;
  // Just in case it didn't happen already release the edit link.
  FEditLink := nil;
  FClipboardFormats.Free;
  // Clear will also free the drag manager if it is still alive.
  Clear;
  FDragImage.Free;
  FColors.Free;
  FBackground.Free;
  FImageChangeLink.Free;
  FStateChangeLink.Free;
  FCustomCheckChangeLink.Free;
  FScrollBarOptions.Free;
  FHeader.Free;

  FreeMem(FRoot);

  FPlusBM.Free;
  FMinusBM.Free;
  ReleaseThreadReference(Self);

  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.AdjustCoordinatesByIndent(var PaintInfo: TVTPaintInfo; Indent: Integer);

// During painting of the main column some coordinates must be adjusted due to the tree lines.
// The offset resulting from the tree lines and indentation level is given in Indent.

var
  Offset: Integer;

begin
  with PaintInfo do
  begin
    Offset := Indent * Integer(FIndent);
    if BidiMode = bdLeftToRight then
    begin
      Inc(ContentRect.Left, Offset);
      Inc(ImageInfo[iiNormal].XPos, Offset);
      Inc(ImageInfo[iiState].XPos, Offset);
      Inc(ImageInfo[iiCheck].XPos, Offset);
    end
    else
    begin
      Dec(ContentRect.Right, Offset);
      Dec(ImageInfo[iiNormal].XPos, Offset);
      Dec(ImageInfo[iiState].XPos, Offset);
      Dec(ImageInfo[iiCheck].XPos, Offset);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.AdjustImageBorder(Images: TImageList; BidiMode: TBidiMode; VAlign: Integer; var R: TRect; 
  var ImageInfo: TVTImageInfo);

// Depending on the width of the image list as well as the given bidi mode R must be adjusted.

begin
  if BidiMode = bdLeftToRight then
  begin
    ImageInfo.XPos := R.Left;
    Inc(R.Left, Images.Width + 2);
  end
  else
  begin
    ImageInfo.XPos := R.Right - Images.Width;
    Dec(R.Right, Images.Width + 2);
  end;
  ImageInfo.YPos := R.Top + VAlign - Images.Height div 2;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.AdjustTotalCount(Node: PVirtualNode; Value: Integer; relative: Boolean = False);

// Sets a node's total count to the given value and recursively adjusts the parent's total count
// (actually, the adjustment is done iteratively to avoid function call overheads).

var
  Difference: Integer;
  Run: PVirtualNode;

begin
  if relative then
    Difference := Value
  else 
    Difference := Integer(Value) - Integer(Node.TotalCount);
  if Difference <> 0 then
  begin
    Run := Node;
    // root node has as parent the tree view
    while Assigned(Run) and (Run <> Pointer(Self)) do
    begin
      Inc(Integer(Run.TotalCount), Difference);
      Run := Run.Parent;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.AdjustTotalHeight(Node: PVirtualNode; Value: Integer; relative: Boolean = False);

// Sets a node's total height to the given value and recursively adjusts the parent's total height.

var
  Difference: Integer;
  Run: PVirtualNode;

begin
  if relative then
    Difference := Value
  else
    Difference := Integer(Value) - Integer(Node.TotalHeight);
  if Difference <> 0 then
  begin
    Run := Node;
    repeat
      Inc(Integer(Run.TotalHeight), Difference);
      // If the node is not visible or the parent node is not expanded or we are already at the top
      // then nothing more remains to do.
      if not (vsVisible in Run.States) or (Run = FRoot) or
        (Run.Parent = nil) or not (vsExpanded in Run.Parent.States) then
        Break;

      Run := Run.Parent;
    until False;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.CalculateCacheEntryCount: Integer;

// calculates size of cache

begin
  if FVisibleCount > 1 then
    Result := Ceil(FVisibleCount / CacheThreshold)
  else
    Result := 0;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.CalculateVerticalAlignments(ShowImages, ShowStateImages: Boolean; Node: PVirtualNode;
  var VAlign, VButtonAlign: Integer);

// Calculates the vertical alignment of the given node and its associated expand/collapse button during
// a node paint cycle depending on the required node alignment style.

begin
  // For absolute alignment the caluclation is trivial.
  case FNodeAlignment of
    naFromTop:
      VAlign := Node.Align;
    naFromBottom:
      VAlign := Node.NodeHeight - Node.Align;
  else // naProportional
    // Consider button and line alignment, but make sure neither the image nor the button (whichever is taller)
    // go out of the entire node height (100% means bottom alignment to the node's bounds).
    if ShowImages or ShowStateImages then
    begin
      if ShowImages then
        VAlign := FImages.Height
      else
        VAlign := FStateImages.Height;
      VAlign := MulDiv((Node.NodeHeight - VAlign), Node.Align, 100) + VAlign div 2;
    end
    else
      if toShowButtons in FOptions.FPaintOptions then
        VAlign := MulDiv((Node.NodeHeight - FPlusBM.Height), Node.Align, 100) + FPlusBM.Height div 2
      else
        VAlign := MulDiv(Node.NodeHeight, Node.Align, 100);
  end;

  VButtonAlign := VAlign - FPlusBM.Height div 2;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.ChangeCheckState(Node: PVirtualNode; Value: TCheckState): Boolean;

// Sets the check state of the node according to the given value and the node's check type.
// If the check state must be propagated to the parent nodes and one of them refuses to change then
// nothing happens and False is returned, otherwise True.

var
  Run: PVirtualNode;

begin
  with Node^ do
  begin
    Include(States, vsChecking);

    // Do actions which are associated with the given check state.
    case CheckType of
      // Check state change with additional consequences for check states of the children.
      ctTriStateCheckBox:
        begin
          // propagate state down to the children
          if toAutoTristateTracking in FOptions.FAutoOptions then
            case Value of
              csUncheckedNormal:
                begin
                  Run := FirstChild;
                  while Assigned(Run) do
                  begin
                    if Run.CheckType in [ctCheckBox, ctTriStateCheckBox] then
                      SetCheckState(Run, csUncheckedNormal);
                    Run := Run.NextSibling;
                  end;
                end;
              csCheckedNormal:
                begin
                  Run := FirstChild;
                  while Assigned(Run) do
                  begin
                    if Run.CheckType in [ctCheckBox, ctTriStateCheckBox] then
                      SetCheckState(Run, csCheckedNormal);
                    Run := Run.NextSibling;
                  end;
                end;
            end;
        end;
      // radio button check state change
      ctRadioButton:
        if Value = csCheckedNormal then
        begin
          Value := csCheckedNormal;
          // Make sure only this node is checked.
          Run := Parent.FirstChild;
          while Assigned(Run) do
          begin
            if Run.CheckType = ctRadioButton then
              Run.CheckState := csUncheckedNormal;
            Run := Run.NextSibling;
          end;
          Invalidate;
        end;
    end;

    // Propagate state up to the parent.
    if not (vsInitialized in Parent.States) then
      InitNode(Parent);
    if (toAutoTristateTracking in FOptions.FAutoOptions) and ([vsChecking, vsDisabled] * Parent.States = []) and
      (CheckType in [ctCheckBox, ctTriStateCheckBox]) and (Parent <> FRoot) and
      (Parent.CheckType = ctTriStateCheckBox) then
      Result := CheckParentCheckState(Node, Value)
    else
      Result := True;

    if Result then
    begin
      CheckState := Value;
      InvalidateNode(Node);
    end;
    Exclude(States, vsChecking);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.CollectSelectedNodesLTR(MainColumn, NodeLeft, NodeRight: Integer; Alignment: TAlignment;
  OldRect, NewRect: TRect): Boolean;

// Helper routine used when a draw selection takes place. This version handles left-to-right directionality.
// In the process of adding or removing nodes the current selection is modified which requires to pack it after
// the function returns. Another side effect of this method is that a temporary list of nodes will be created
// (see also InternalCacheNode) which must be inserted into the current selection by the caller.

var
  Run,
  NextNode: PVirtualNode;
  TextRight,
  TextLeft,
  CheckOffset,
  CurrentTop,
  CurrentRight,
  NextTop,
  NextColumn,
  NodeWidth,
  Dummy: Integer;
  MinY, MaxY: Integer;
  ImageOffset,
  StateImageOffset: Integer;
  IsInOldRect,
  IsInNewRect: Boolean;

  // quick check variables for various parameters
  WithCheck,
  WithImages,
  WithStateImages,
  DoSwitch,
  AutoSpan,
  Ghosted: Boolean;

begin
  // a priory nothing changes
  Result := False;

  // Determine minimum and maximum vertical coordinates to limit iteration to.
  MinY := Min(OldRect.Top, NewRect.Top);
  MaxY := Max(OldRect.Bottom, NewRect.Bottom);

  // Initialize short hand variables to speed up tests below.
  DoSwitch := ssCtrl in FDrawSelShiftState;
  WithCheck := (toCheckSupport in FOptions.FMiscOptions) and Assigned(FCheckImages);
  // Don't check the events here as descentant trees might have overriden the DoGetImageIndex method.
  WithImages := Assigned(FImages);
  if WithImages then
    ImageOffset := FImages.Width + 2
  else
    ImageOffset := 0;
  WithStateImages := Assigned(FStateImages);
  if WithStateImages then
    StateImageOffset := FStateImages.Width + 2
  else
    StateImageOffset := 0;
  if WithCheck then
    CheckOffset := FCheckImages.Width + 2
  else
    CheckOffset := 0;
  AutoSpan := FHeader.UseColumns and (toAutoSpanColumns in FOptions.FAutoOptions);

  // This is the node to start with.
  Run := GetNodeAt(0, MinY, False, CurrentTop);

  if Assigned(Run) then
  begin
    // The initial minimal left border is determined by the identation level of the node and is dynamically adjusted.
    if toShowRoot in FOptions.FPaintOptions then
      Inc(NodeLeft, Integer((GetNodeLevel(Run) + 1) * FIndent) + FMargin)
    else
      Inc(NodeLeft, Integer(GetNodeLevel(Run) * FIndent) + FMargin);

    // ----- main loop
    // Change selection depending on the node's rectangle being in the selection rectangle or not, but
    // touch only those nodes which overlap either the old selection rectangle or the new one but not both.
    repeat
      // Collect offsets for check, normal and state images.
      TextLeft := NodeLeft;
      if WithCheck and (Run.CheckType <> ctNone) then
        Inc(TextLeft, CheckOffset);
      if WithImages and (GetImageIndex(Run, ikNormal, MainColumn, Ghosted) > -1) then
        Inc(TextLeft, ImageOffset);
      if WithStateImages and (GetImageIndex(Run, ikState, MainColumn, Ghosted) > -1) then
        Inc(TextLeft, StateImageOffset);

      NextTop := CurrentTop + Run.NodeHeight;

      // The right column border might be extended if column spanning is enabled.
      if AutoSpan then
      begin
        with FHeader.FColumns do
        begin
          NextColumn := MainColumn;
          repeat
            Dummy := GetNextVisibleColumn(NextColumn);
            if (Dummy = InvalidColumn) or not ColumnIsEmpty(Run, Dummy) or
              (Items[Dummy].BidiMode <> bdLeftToRight) then
              Break;
            NextColumn := Dummy;
          until False;
          if NextColumn = MainColumn then
            CurrentRight := NodeRight
          else
            GetColumnBounds(NextColumn, Dummy, CurrentRight);
        end;
      end
      else
        CurrentRight := NodeRight;

      // Check if we need the node's width. This is the case when the node is not left aligned or the
      // left border of the selection rectangle is to the right of the left node border.
      if (TextLeft < OldRect.Left) or (TextLeft < NewRect.Left) or (Alignment <> taLeftJustify) then
      begin
        NodeWidth := DoGetNodeWidth(Run, MainColumn);
        if NodeWidth >= (CurrentRight - TextLeft) then
          TextRight := CurrentRight
        else
          case Alignment of
            taLeftJustify:
              TextRight := TextLeft + NodeWidth;
            taCenter:
              begin
                TextLeft := (TextLeft + CurrentRight - NodeWidth) div 2;
                TextRight := TextLeft + NodeWidth;
              end;
          else
            // taRightJustify
            TextRight := CurrentRight;
            TextLeft := TextRight - NodeWidth;
          end;
      end
      else
        TextRight := CurrentRight;

      // Now determine whether we need to change the state.
      IsInOldRect := (OldRect.Left <= TextRight) and (OldRect.Right >= TextLeft) and
        (NextTop > OldRect.Top) and (CurrentTop < OldRect.Bottom);
      IsInNewRect := (NewRect.Left <= TextRight) and (NewRect.Right >= TextLeft) and
        (NextTop > NewRect.Top) and (CurrentTop < NewRect.Bottom);

      if IsInOldRect xor IsInNewRect then
      begin
        Result := True;
        if DoSwitch then
        begin
          if vsSelected in Run.States then
            InternalRemoveFromSelection(Run)
          else
            InternalCacheNode(Run);
        end
        else
        begin
          if IsInNewRect then
            InternalCacheNode(Run)
          else
            InternalRemoveFromSelection(Run);
        end;
      end;

      CurrentTop := NextTop;
      // Get next visible node and update left node position.
      NextNode := GetNextVisibleNoInit(Run);
      if NextNode = nil then
        Break;
      Inc(NodeLeft, CountLevelDifference(Run, NextNode) * Integer(FIndent));
      Run := NextNode;
    until CurrentTop > MaxY;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.CollectSelectedNodesRTL(MainColumn, NodeLeft, NodeRight: Integer; Alignment: TAlignment;
  OldRect, NewRect: TRect): Boolean;

// Helper routine used when a draw selection takes place. This version handles right-to-left directionality.
// See also comments in CollectSelectedNodesLTR.

var
  Run,
  NextNode: PVirtualNode;
  TextRight,
  TextLeft,
  CheckOffset,
  CurrentTop,
  CurrentLeft,
  NextTop,
  NextColumn,
  NodeWidth,
  Dummy: Integer;
  MinY, MaxY: Integer;
  ImageOffset,
  StateImageOffset: Integer;
  IsInOldRect,
  IsInNewRect: Boolean;
  
  // quick check variables for various parameters
  WithCheck,
  WithImages,
  WithStateImages,
  DoSwitch,
  AutoSpan,
  Ghosted: Boolean;

begin
  // A priori nothing changes.
  Result := False;
  // Switch the alignment to the opposite value in RTL context.
  ChangeBiDiModeAlignment(Alignment);

  // Determine minimum and maximum vertical coordinates to limit iteration to.
  MinY := Min(OldRect.Top, NewRect.Top);
  MaxY := Max(OldRect.Bottom, NewRect.Bottom);

  // Initialize short hand variables to speed up tests below.
  DoSwitch := ssCtrl in FDrawSelShiftState;
  WithCheck := (toCheckSupport in FOptions.FMiscOptions) and Assigned(FCheckImages);
  // Don't check the events here as descentant trees might have overriden the DoGetImageIndex method.
  WithImages := Assigned(FImages);
  if WithImages then
    ImageOffset := FImages.Width + 2
  else
    ImageOffset := 0;
  WithStateImages := Assigned(FStateImages);
  if WithStateImages then
    StateImageOffset := FStateImages.Width + 2
  else
    StateImageOffset := 0;
  if WithCheck then
    CheckOffset := FCheckImages.Width + 2
  else
    CheckOffset := 0;
  AutoSpan := FHeader.UseColumns and (toAutoSpanColumns in FOptions.FAutoOptions);

  // This is the node to start with.
  Run := GetNodeAt(0, MinY, False, CurrentTop);

  if Assigned(Run) then
  begin
    // The initial minimal left border is determined by the identation level of the node and is dynamically adjusted.
    if toShowRoot in FOptions.FPaintOptions then
      Dec(NodeRight, Integer((GetNodeLevel(Run) + 1) * FIndent) + FMargin)
    else
      Dec(NodeRight, Integer(GetNodeLevel(Run) * FIndent) + FMargin);

    // ----- main loop
    // Change selection depending on the node's rectangle being in the selection rectangle or not, but
    // touch only those nodes which overlap either the old selection rectangle or the new one but not both.
    repeat
      // Collect offsets for check, normal and state images.
      TextRight := NodeRight;
      if WithCheck and (Run.CheckType <> ctNone) then
        Dec(TextRight, CheckOffset);
      if WithImages and (GetImageIndex(Run, ikNormal, MainColumn, Ghosted) > -1) then
        Dec(TextRight, ImageOffset);
      if WithStateImages and (GetImageIndex(Run, ikState, MainColumn, Ghosted) > -1) then
        Dec(TextRight, StateImageOffset);

      NextTop := CurrentTop + Run.NodeHeight;

      // The left column border might be extended if column spanning is enabled.
      if AutoSpan then
      begin
        NextColumn := MainColumn;
        repeat
          Dummy := FHeader.FColumns.GetPreviousVisibleColumn(NextColumn);
          if (Dummy = InvalidColumn) or not ColumnIsEmpty(Run, Dummy) or
            (FHeader.FColumns[Dummy].BiDiMode = bdLeftToRight) then
            Break;
          NextColumn := Dummy;
        until False;
        if NextColumn = MainColumn then
          CurrentLeft := NodeLeft
        else
          FHeader.FColumns.GetColumnBounds(NextColumn, CurrentLeft, Dummy);
      end
      else
        CurrentLeft := NodeLeft;
    
      // Check if we need the node's width. This is the case when the node is not left aligned (in RTL context this
      // means actually right aligned) or the right border of the selection rectangle is to the left
      // of the right node border.
      if (TextRight > OldRect.Right) or (TextRight > NewRect.Right) or (Alignment <> taRightJustify) then
      begin
        NodeWidth := DoGetNodeWidth(Run, MainColumn);
        if NodeWidth >= (TextRight - CurrentLeft) then
          TextLeft := CurrentLeft
        else
          case Alignment of
            taLeftJustify:
              begin
                TextLeft := CurrentLeft;
                TextRight := TextLeft + NodeWidth;
              end;
            taCenter:
              begin
                TextLeft := (TextRight + CurrentLeft - NodeWidth) div 2;
                TextRight := TextLeft + NodeWidth;
              end;
          else
            // taRightJustify
            TextLeft := TextRight - NodeWidth;
          end;
      end
      else
        TextLeft := CurrentLeft;

      // Now determine whether we need to change the state.
      IsInOldRect := (OldRect.Right >= TextLeft) and (OldRect.Left <= TextRight) and
        (NextTop > OldRect.Top) and (CurrentTop < OldRect.Bottom);
      IsInNewRect := (NewRect.Right >= TextLeft) and (NewRect.Left <= TextRight) and
        (NextTop > NewRect.Top) and (CurrentTop < NewRect.Bottom);

      if IsInOldRect xor IsInNewRect then
      begin
        Result := True;
        if DoSwitch then
        begin
          if vsSelected in Run.States then
            InternalRemoveFromSelection(Run)
          else
            InternalCacheNode(Run);
        end
        else
        begin
          if IsInNewRect then
            InternalCacheNode(Run)
          else
            InternalRemoveFromSelection(Run);
        end;
      end;

      CurrentTop := NextTop;
      // Get next visible node and update left node position.
      NextNode := GetNextVisibleNoInit(Run);
      if NextNode = nil then
        Break;
      Dec(NodeRight, CountLevelDifference(Run, NextNode) * Integer(FIndent));
      Run := NextNode;
    until CurrentTop > MaxY;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.ClearNodeBackground(Canvas: TCanvas; Node: PVirtualNode; UseBackground, Floating: Boolean;
  R: TRect);

// Erases a nodes background depending on what the application decides to do.
// UseBackground determines whether or not to use the background picture, while Floating indicates
// that R is given in coordinates of the small node bitmap or the superordinated target bitmap used in PaintTree.

var
  BackColor: TColor;
  EraseAction: TItemEraseAction;
  Offset: TPoint;

begin
  EraseAction := eaDefault;
  BackColor := Color;
  DoBeforeItemErase(Canvas, Node, R, Backcolor, EraseAction);
  if Floating then
  begin
    Offset := Point(FOffsetX, R.Top);
    OffsetRect(R, 0, -Offset.Y);
  end
  else
    Offset := Point(0, 0);

  with Canvas do
  begin
    case EraseAction of
      eaColor:
        begin
          // user has given a new background color
          Brush.Color := BackColor;
          FillRect(R);
          DoAfterItemErase(Canvas, Node, R);
        end;
    else // eaDefault
      if UseBackground then
        TileBackground(FBackground.Bitmap, Canvas, Offset, R)
      else
      begin
        if (toFullRowSelect in FOptions.FSelectionOptions) and (vsSelected in Node.States) then
        begin
          if toShowHorzGridLines in FOptions.PaintOptions then
            Dec(R.Bottom);
          if Focused or (toPopupMode in FOptions.FPaintOptions)then
          begin
            Brush.Color := FColors.FocusedSelectionColor;
            Pen.Color := FColors.FocusedSelectionBorderColor;
          end
          else
          begin
            Brush.Color := FColors.UnfocusedSelectionColor;
            Pen.Color := FColors.UnfocusedSelectionBorderColor;
          end;
          with R do
            RoundRect(Left, Top, Right, Bottom, FSelectionCurveRadius, FSelectionCurveRadius);
        end
        else
        begin
          Brush.Color := Color;
          FillRect(R);
        end;
      end;
      DoAfterItemErase(Canvas, Node, R);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.CompareNodePositions(Node1, Node2: PVirtualNode): Integer;

// tries hard and smart to quickly determine whether Node1's structural position is before Node2's position
// Returns 0 if Node1 = Node2, < 0 if Node1 is located before Node2 else > 0.

var
  Run1,
  Run2: PVirtualNode;
  Level1,
  Level2: Cardinal;

begin
  Assert(Assigned(Node1) and Assigned(Node2), 'Nodes must never be nil.');

  if Node1 = Node2 then
    Result := 0
  else
  begin
    if HasAsParent(Node1, Node2) then
      Result := 1
    else
      if HasAsParent(Node2, Node1) then
        Result := -1
      else
      begin
        // the given nodes are neither equal nor are they parents of each other, so go up to FRoot
        // for each node and compare the child indices of the top level parents
        // Note: neither Node1 nor Node2 can be FRoot at this point as this (a bit strange) circumstance would
        //       be caught by the previous code.

        // start lookup at the same level
        Level1 := GetNodeLevel(Node1);
        Level2 := GetNodeLevel(Node2);
        Run1 := Node1;
        while Level1 > Level2 do
        begin
          Run1 := Run1.Parent;
          Dec(Level1);
        end;
        Run2 := Node2;
        while Level2 > Level1 do
        begin
          Run2 := Run2.Parent;
          Dec(Level2);
        end;

        // now go up until we find a common parent node (loop will safely stop at FRoot if the nodes
        // don't share a common parent)
        while Run1.Parent <> Run2.Parent do
        begin
          Run1 := Run1.Parent;
          Run2 := Run2.Parent;
        end;
        Result := Integer(Run1.Index) - Integer(Run2.Index);
      end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.DetermineNextCheckState(CheckType: TCheckType; CheckState: TCheckState): TCheckState;

// Determines the next check state in case the user click the check image or pressed the space key.

begin
  case CheckType of
    ctTriStateCheckBox,
    ctCheckBox:
      if CheckState = csCheckedNormal then
        Result := csUncheckedNormal
      else
        Result := csCheckedNormal;
    ctRadioButton:
      Result := csCheckedNormal;
    ctButton:
      Result := csUncheckedNormal;
  else
    Result := csMixedNormal;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DrawLineImage(const PaintInfo: TVTPaintInfo; X, Y, H, VAlign: Integer; Style: TVTLineType;
  Reverse: Boolean);

// Draws (depending on Style) one of the 5 line types of the tree.
// If Reverse is True then a right-to-left column is being drawn, hence horizontal lines must be mirrored.
// X and Y describe the left upper corner of the line image rectangle, while H denotes its height (and width).

var
  HalfWidth,
  TargetX: Integer;

begin
  HalfWidth := Integer(FIndent) div 2;
  if Reverse then
    TargetX := 0
  else
    TargetX := FIndent;

  with PaintInfo.Canvas do
  begin
    case Style of
      ltBottomRight:
        begin
          DrawDottedVLine(PaintInfo, Y + VAlign, Y + H, X + HalfWidth);
          DrawDottedHLine(PaintInfo, X + HalfWidth, X + TargetX, Y + VAlign);
        end;
      ltTopDown:
        DrawDottedVLine(PaintInfo, Y, Y + H, X + HalfWidth);
      ltTopDownRight:
        begin
          DrawDottedVLine(PaintInfo, Y, Y + H, X + HalfWidth);
          DrawDottedHLine(PaintInfo, X + HalfWidth, X + TargetX, Y + VAlign);
        end;
      ltRight:
        DrawDottedHLine(PaintInfo, X + HalfWidth, X + TargetX, Y + VAlign);
      ltTopRight:
        begin
          DrawDottedVLine(PaintInfo, Y, Y + VAlign, X + HalfWidth);
          DrawDottedHLine(PaintInfo, X + HalfWidth, X + TargetX, Y + VAlign);
        end;
      ltLeft: // left can also mean right for RTL context
        if Reverse then
          DrawDottedVLine(PaintInfo, Y, Y + H, X + Integer(FIndent))
        else
          DrawDottedVLine(PaintInfo, Y, Y + H, X);
      ltLeftBottom:
        if Reverse then
        begin
          DrawDottedVLine(PaintInfo, Y, Y + H, X + Integer(FIndent));
          DrawDottedHLine(PaintInfo, X, X + Integer(FIndent), Y + H);
        end
        else
        begin
          DrawDottedVLine(PaintInfo, Y, Y + H, X);
          DrawDottedHLine(PaintInfo, X, X + Integer(FIndent), Y + H);
        end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.FindInPositionCache(Node: PVirtualNode; var CurrentPos: Cardinal): PVirtualNode;

// Looks through the position cache and returns the node whose top position is the largest one which is smaller or equal
// to the position of the given node.

var
  L, H, I: Integer;

begin
  L := 0;
  H := High(FPositionCache);
  while L <= H do
  begin
    I := (L + H) shr 1;
    if CompareNodePositions(FPositionCache[I].Node, Node) <= 0 then
      L := I + 1
    else
      H := I - 1;
  end;
  Result := FPositionCache[L - 1].Node;
  CurrentPos := FPositionCache[L - 1].AbsoluteTop;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.FindInPositionCache(Position: Cardinal; var CurrentPos: Cardinal): PVirtualNode;

// Looks through the position cache and returns the node whose top position is the largest one which is smaller or equal
// to the given vertical position.
// The returned node does not necessarily occupy the given position but is the nearest one to start
// iterating from to approach the real node for a given position. CurrentPos receives the actual position of the found
// node which is needed for further iteration.

var
  L, H, I: Integer;

begin
  L := 0;
  H := High(FPositionCache);
  while L <= H do
  begin
    I := (L + H) shr 1;
    if FPositionCache[I].AbsoluteTop <= Position then
      L := I + 1
    else
      H := I - 1;
  end;
  Result := FPositionCache[L - 1].Node;
  CurrentPos := FPositionCache[L - 1].AbsoluteTop;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.FontChanged(AFont: TObject);

// Little helper function for font changes (as they are not tracked in TBitmap/TCanvas.OnChange).

begin
  FFontChanged := True;
  FOldFontChange(AFont);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetCheckState(Node: PVirtualNode): TCheckState;

begin
  Result := Node.CheckState;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetCheckType(Node: PVirtualNode): TCheckType;

begin
  Result := Node.CheckType;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetChildCount(Node: PVirtualNode): Cardinal;

begin
  if (Node = nil) or (Node = FRoot) then
    Result := FRoot.ChildCount
  else
    Result := Node.ChildCount;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetChildrenInitialized(Node: PVirtualNode): Boolean;

begin
  Result := not (vsHasChildren in Node.States) or (Node.ChildCount > 0);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetDisabled(Node: PVirtualNode): Boolean;

begin
  Result := Assigned(Node) and (vsDisabled in Node.States);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetDragManager: IVTDragManager;

// Returns the internal drag manager interface. If this does not yet exist then it is created here.

begin
  if FDragManager = nil then
  begin
    FDragManager := DoCreateDragManager;
    if FDragManager = nil then
      FDragManager := TVTDragManager.Create(Self);
  end;

  Result := FDragManager;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetExpanded(Node: PVirtualNode): Boolean;

begin
  if Assigned(Node) then
    Result := vsExpanded in Node.States
  else
    Result := False;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetFullyVisible(Node: PVirtualNode): Boolean;

// Determines whether the given node has the visibility flag set as well as all its parents are expanded.

begin
  Assert(Assigned(Node), 'Invalid parameter.');
  Result := vsVisible in Node.States;
  if Result and (Node <> FRoot) then
    Result := VisiblePath[Node];
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetHasChildren(Node: PVirtualNode): Boolean;

begin
  if Assigned(Node) then
    Result := vsHasChildren in Node.States
  else
    Result := vsHasChildren in FRoot.States;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetNodeHeight(Node: PVirtualNode): Cardinal;

begin
  if Assigned(Node) and (Node <> FRoot) then
    Result := Node.NodeHeight
  else
    Result := 0;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetOffsetXY: TPoint;

begin
  Result := Point(FOffsetX, FOffsetY);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetRootNodeCount: Cardinal;

begin
  Result := FRoot.ChildCount;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetSelected(Node: PVirtualNode): Boolean;

begin
  Result := Assigned(Node) and (vsSelected in Node.States);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetTopNode: PVirtualNode;

var
  Dummy: Integer;

begin
  Result := GetNodeAt(0, 0, True, Dummy);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetTotalCount: Cardinal;

begin
  BeginUpdate;
  try
    ValidateNode(FRoot, True);
  finally
    EndUpdate;
  end;
  // The root node itself doesn't count as node.
  Result := FRoot.TotalCount - 1;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetVerticalAlignment(Node: PVirtualNode): Byte;

begin
  Result := Node.Align;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetVisible(Node: PVirtualNode): Boolean;

// Determines if the given node marked as being visible.

begin
  if Node = nil then
    Node := FRoot;

  if not (vsInitialized in Node.States) then
    InitNode(Node);

  Result := vsVisible in Node.States;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetVisiblePath(Node: PVirtualNode): Boolean;

// Determines if all parents of the given node are expanded and have the visibility flag set.

begin
  Assert(Assigned(Node) and (Node <> FRoot), 'Invalid parameters.');

  // FRoot is always expanded
  repeat
    Node := Node.Parent;
  until (Node = FRoot) or not (vsExpanded in Node.States) or not (vsVisible in Node.States);

  Result := Node = FRoot;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.HandleClickSelection(LastFocused, NewNode: PVirtualNode; Shift: TShiftState);

// Handles multi-selection with mouse click.

begin
  // Ctrl key down
  if ssCtrl in Shift then
  begin
    if ssShift in Shift then
    begin
      SelectNodes(FRangeAnchor, NewNode, True);
      Invalidate;
    end
    else
    begin
      if not (toSiblingSelectConstraint in FOptions.SelectionOptions) then
        FRangeAnchor := NewNode;
      if vsSelected in NewNode.States then
        RemoveFromSelection(NewNode)
      else
        AddToSelection(NewNode);
      InvalidateNode(NewNode);
    end;
  end
  else
    // Shift key down
    if ssShift in Shift then
    begin
      if FRangeAnchor = nil then
        FRangeAnchor := FRoot.FirstChild;

      // select node range
      if Assigned(FRangeAnchor) then
      begin
        SelectNodes(FRangeAnchor, NewNode, False);
        Invalidate;
      end;
    end
    else
    begin
      // any other case
      if not (vsSelected in NewNode.States) then
      begin
        AddToSelection(NewNode);
        InvalidateNode(NewNode);
      end;
      // assign new reference item
      FRangeAnchor := NewNode;
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.HandleDrawSelection(X, Y: Integer): Boolean;

// Handles multi-selection with a focus rectangle.
// Result is True if something changed in selection.

var
  OldRect,
  NewRect: TRect;
  MainColumn: Integer;
  MaxValue: Integer;

  // limits of a node and its text
  NodeLeft,
  NodeRight: Integer;

  // alignment and directionality
  CurrentBidiMode: TBidiMode;
  CurrentAlignment: TAlignment;

begin
  Result := False;

  // Selection changes are only done if the user drew a selection rectangle large
  // enough to exceed the threshold.
  if (FRoot.TotalCount > 1) and (tsDrawSelecting in FStates) then
  begin
    // Effective handling of node selection is done by using two rectangles stored in FSelectRec.
    OldRect := OrderRect(FLastSelRect);
    NewRect := OrderRect(FNewSelRect);
    ClearTempCache;

    MainColumn := FHeader.MainColumn;

    // Alignment and bidi mode determine where the node text is located within a node.
    if MainColumn = NoColumn then
    begin
      CurrentBidiMode := BidiMode;
      CurrentAlignment := Alignment;
    end
    else
    begin
      CurrentBidiMode := FHeader.FColumns[MainColumn].BidiMode;
      CurrentAlignment := FHeader.FColumns[MainColumn].Alignment;
    end;

    // Determine initial left border of first node (take column reordering into account).
    if FHeader.UseColumns then
    begin
      // The mouse coordinates don't include any horizontal scrolling hence take this also
      // out from the returned column position.
      NodeLeft := FHeader.FColumns[MainColumn].Left - FOffsetX;
      NodeRight := NodeLeft + FHeader.FColumns[MainColumn].Width;
    end
    else
    begin
      NodeLeft := 0;
      NodeRight := ClientWidth;
    end;
    if CurrentBidiMode = bdLeftToRight then
      Result := CollectSelectedNodesLTR(MainColumn, NodeLeft, NodeRight, CurrentAlignment, OldRect, NewRect)
    else
      Result := CollectSelectedNodesRTL(MainColumn, NodeLeft, NodeRight, CurrentAlignment, OldRect, NewRect);
  end;

  if Result then
  begin
    // Do some housekeeping if there was a change.
    MaxValue := PackArray(FSelection, FSelectionCount);
    if MaxValue > -1 then
    begin
      FSelectionCount := MaxValue;
      SetLength(FSelection, FSelectionCount);
    end;
    if FTempNodeCount > 0 then
    begin
      AddToSelection(FTempNodeCache, FTempNodeCount);
      ClearTempCache;
    end;

    Change(nil);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.HasVisibleNextSibling(Node: PVirtualNode): Boolean;

// Helper method to determine if the given node has a visible sibling. This is needed to
// draw correct tree lines.

begin
  // Check if there is a sibling at all.
  Result := Assigned(Node.NextSibling);

  if Result then
  begin
    repeat
      Node := Node.NextSibling;
      Result := vsVisible in Node.States;
    until Result or (Node.NextSibling = nil);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.ImageListChange(Sender: TObject);

begin
  if not (csDestroying in ComponentState) then
    Invalidate;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.InitializeFirstColumnValues(var PaintInfo: TVTPaintInfo);

// Determines initial index, position and cell size of the first visible column.

begin
  PaintInfo.Column := FHeader.FColumns.GetFirstVisibleColumn;
  with FHeader.FColumns, PaintInfo do
  begin
    if Column > NoColumn then
    begin
      CellRect.Right := CellRect.Left + Items[Column].Width;
      Position := Items[Column].Position;
    end
    else
      Position := 0;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.InitializeLineImageAndSelectLevel(Node: PVirtualNode; var LineImage: TLineImage): Integer;

// This method is used during paint cycles and initializes an array of line type IDs. These IDs are used to paint
// the tree lines in front of the given node.
// Additionally an initial count of selected parents is determined and returned which is used for specific painting.

var
  X: Integer;
  Run: PVirtualNode;

begin
  Result := 0;
  if toShowRoot in FOptions.FPaintOptions then
    X := 1
  else
    X := 0;
  Run := Node;
  // Determine indentation level of top node.
  while Run.Parent <> FRoot do
  begin
    Inc(X);
    Run := Run.Parent;
    // Count selected nodes (FRoot is never selected).
    if vsSelected in Run.States then
      Inc(Result);
  end;

  // Set initial size of line index array, this will automatically initialized all entries to ltNone. 
  SetLength(LineImage, X);

  // Only use lines if requested.
  if toShowTreeLines in FOptions.FPaintOptions then
  begin
    // Start over parent traversal if necessary.
    Run := Node;
    if Run.Parent <> FRoot then
    begin
      // The very last image (the one immediately before the item label) is different.
      if HasVisibleNextSibling(Run) then
        LineImage[X - 1] := ltTopDownRight
      else
        LineImage[X - 1] := ltTopRight;
      Run := Run.Parent;

      // Now go up all parents.
      repeat
        if Run.Parent = FRoot then
          Break;
        Dec(X);
        if HasVisibleNextSibling(Run) then
          LineImage[X - 1] := ltTopDown
        else
          LineImage[X - 1] := ltNone;
        Run := Run.Parent;
      until False;
    end;

    // Prepare root level. Run points at this stage to a top level node.
    if (toShowRoot in FOptions.FPaintOptions) and (toShowTreeLines in FOptions.FPaintOptions) then
    begin
      // Is the top node a root node?
      if Run = Node then
      begin
        // First child gets the bottom-right bitmap if it isn't also the only child.
        if IsFirstVisibleChild(FRoot, Run) then
          // Is it the only child?
          if IsLastVisibleChild(FRoot, Run) then
            LineImage[0] := ltRight
          else
            LineImage[0] := ltBottomRight
        else
          // real last child
          if IsLastVisibleChild(FRoot, Run) then
            LineImage[0] := ltTopRight
          else
            LineImage[0] := ltTopDownRight;
      end
      else
      begin
        // No, top node is not a top level node. So we need different painting.
        if HasVisibleNextSibling(Run) then
          LineImage[0] := ltTopDown
        else
          LineImage[0] := ltNone;
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.InitRootNode(OldSize: Cardinal = 0);

// Reinitializes the root node.

var
  NewSize: Cardinal;

begin
  NewSize := TreeNodeSize + FTotalInternalDataSize;
  if FRoot = nil then
    FRoot := AllocMem(NewSize)
  else
  begin
    ReallocMem(FRoot, NewSize);
    ZeroMemory(PChar(FRoot) + OldSize, NewSize - OldSize);
  end;

  with FRoot^ do
  begin
    // Indication that this node is the root node.
    PrevSibling := FRoot;
    NextSibling := FRoot;
    Parent := Pointer(Self);
    States := [vsInitialized, vsExpanded, vsHasChildren, vsVisible];
    TotalHeight := FDefaultNodeHeight;
    TotalCount := 1;
    TotalHeight := FDefaultNodeHeight;
    NodeHeight := FDefaultNodeHeight;
    Align := 50;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.InternalConnectNode(Node, Destination: PVirtualNode; Target: TBaseVirtualTree;
  Mode: TVTNodeAttachMode);

// Connects Node with Destination depending on Mode.
// No error checking takes place. Node as well as Destination must be valid. Node must never be a root node and
// Destination must not be a root node if Mode is amInsertBefore or amInsertAfter.

var
  Run: PVirtualNode;

begin
  // Keep in mind that the destination node might belong to another tree.
  with Target do
  begin
    case Mode of
      amInsertBefore:
        begin
          Node.PrevSibling := Destination.PrevSibling;
          Destination.PrevSibling := Node;
          Node.NextSibling := Destination;
          Node.Parent := Destination.Parent;
          Node.Index := Destination.Index;
          if Node.PrevSibling = nil then
            Node.Parent.FirstChild := Node
          else
            Node.PrevSibling.NextSibling := Node;

          // reindex all following nodes
          Run := Destination;
          while Assigned(Run) do
          begin
            Inc(Run.Index);
            Run := Run.NextSibling;
          end;

          Inc(Destination.Parent.ChildCount);
          Include(Destination.Parent.States, vsHasChildren);
          AdjustTotalCount(Destination.Parent, Node.TotalCount, True);

          // Add the new node's height only if its parent is expanded (visibility is handled elsewhere).
          if vsExpanded in Destination.Parent.States then
            AdjustTotalHeight(Destination.Parent, Node.TotalHeight, True);
          if FullyVisible[Destination.Parent] then
            Inc(FVisibleCount, CountVisibleChildren(Node) + 1);
        end;
      amInsertAfter:
        begin
          Node.NextSibling := Destination.NextSibling;
          Destination.NextSibling := Node;
          Node.PrevSibling := Destination;
          Node.Parent := Destination.Parent;
          if Node.NextSibling = nil then
            Node.Parent.LastChild := Node
          else
            Node.NextSibling.PrevSibling := Node;
          Node.Index := Destination.Index;

          // reindex all following nodes
          Run := Node;
          while Assigned(Run) do
          begin
            Inc(Run.Index);
            Run := Run.NextSibling;
          end;

          Inc(Destination.Parent.ChildCount);
          Include(Destination.Parent.States, vsHasChildren);
          AdjustTotalCount(Destination.Parent, Node.TotalCount, True);
          // Add the new node's height only if its parent is expanded (visibility is handled elsewhere).
          if vsExpanded in Destination.Parent.States then
            AdjustTotalHeight(Destination.Parent, Node.TotalHeight, True);
          if FullyVisible[Destination.Parent] then
            Inc(FVisibleCount, CountVisibleChildren(Node) + 1);
        end;
      amAddChildFirst:
        begin
          if Assigned(Destination.FirstChild) then
          begin
            // If there's a first child then there must also be a last child.
            Destination.FirstChild.PrevSibling := Node;
            Node.NextSibling := Destination.FirstChild;
            Destination.FirstChild := Node;
          end
          else
          begin
            // First child node at this location.
            Destination.FirstChild := Node;
            Destination.LastChild := Node;
            Node.NextSibling := nil;
          end;
          Node.PrevSibling := nil;
          Node.Parent := Destination;
          Node.Index := 0;
          // reindex all following nodes
          Run := Node.NextSibling;
          while Assigned(Run) do
          begin
            Inc(Run.Index);
            Run := Run.NextSibling;
          end;

          Inc(Destination.ChildCount);
          Include(Destination.States, vsHasChildren);
          AdjustTotalCount(Destination, Node.TotalCount, True);
          // add the new node's height only if its parent is expanded (visibility is handled elsewhere)
          if vsExpanded in Destination.States then
            AdjustTotalHeight(Destination, Node.TotalHeight, True);
          if FullyVisible[Destination] then
            Inc(FVisibleCount, CountVisibleChildren(Node) + 1);
        end;
      amAddChildLast:
        begin
          if Assigned(Destination.LastChild) then
          begin
            // if there's a last child then there must also be a first child
            Destination.LastChild.NextSibling := Node;
            Node.PrevSibling := Destination.LastChild;
            Destination.LastChild := Node;
          end
          else
          begin
            // first child node at this location
            Destination.FirstChild := Node;
            Destination.LastChild := Node;
            Node.PrevSibling := nil;
          end;
          Node.NextSibling := nil;
          Node.Parent := Destination;
          if Assigned(Node.PrevSibling) then
            Node.Index := Node.PrevSibling.Index + 1
          else
            Node.Index := 0;
          Inc(Destination.ChildCount);
          Include(Destination.States, vsHasChildren);
          AdjustTotalCount(Destination, Node.TotalCount, True);
          // Add the new node's height only if its parent is expanded (visibility is handled elsewhere).
          if vsExpanded in Destination.States then
            AdjustTotalHeight(Destination, Node.TotalHeight, True);
          if FullyVisible[Node] then
            Inc(FVisibleCount, CountVisibleChildren(Node) + 1);
        end;
    else
      // amNoWhere: do nothing
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.InternalDisconnectNode(Node: PVirtualNode; KeepFocus: Boolean);

// Disconnects the given node from its parent and siblings. The node's pointer are not reset so they can still be used
// after return from this method (probably a very short time only!).
// If KeepFocus is True then the focused node is not reset. This is useful if the given node is reconnected to the tree
// immediately after return of this method and should stay being the focused node if it was it before.
// Note: Node must not be nil or the root node.

var
  Parent,
  Run: PVirtualNode;

begin
  Assert(Assigned(Node) and (Node <> FRoot), 'Node must neither be nil nor the root node.');

  if (Node = FFocusedNode) and not KeepFocus then
  begin
    DoFocusNode(nil, False);
    DoFocusChange(FFocusedNode, FFocusedColumn);
  end;

  if Node = FRangeAnchor then
    ResetRangeAnchor;

  if not (vsDeleting in Node.States) then
  begin
    // Some states are only temporary so take them out.
    Node.States := Node.States - [vsChecking];
    Parent := Node.Parent;
    Dec(Parent.ChildCount);
    if Parent.ChildCount = 0 then
      Exclude(Parent.States, vsHasChildren);
    AdjustTotalCount(Parent, -Integer(Node.TotalCount), True);
    if vsExpanded in Parent.States then
      AdjustTotalHeight(Parent, -Integer(Node.TotalHeight), True);
    if FullyVisible[Node] then
      Dec(FVisibleCount, CountVisibleChildren(Node) + 1);
    if Assigned(Node.PrevSibling) then
      Node.PrevSibling.NextSibling := Node.NextSibling
    else
      Parent.FirstChild := Node.NextSibling;

    if Assigned(Node.NextSibling) then
    begin
      Node.NextSibling.PrevSibling := Node.PrevSibling;
      // Reindex all following nodes.
      Run := Node.NextSibling;
      while Assigned(Run) do
      begin
        Dec(Run.Index);
        Run := Run.NextSibling;
      end;
    end
    else
      Parent.LastChild := Node.PrevSibling;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.InterruptValidation;

// waits until the worker thread has stopped validating the caches of this tree

begin
  if WorkerThread=nil then exit;
  
  if tsValidating in FStates then
  begin
    Include(FStates, tsStopValidation);
    // make a hard break until the worker thread has stopped validation
    WorkerThread.Priority := tpHighest;
    while tsValidating in FStates do
    begin
      Sleep(100);
      // just to be on the safe side...
      if WorkerThread.FCurrentTree <> Self then
      begin
        FStates := FStates - [tsValidating, tsStopValidation];
        Break;
      end;
    end;
    WorkerThread.Priority := tpNormal;
    Include(FStates, tsValidationNeeded);
  end
  else // remove any pending validation
    WorkerThread.RemoveTree(Self);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.IsFirstVisibleChild(Parent, Node: PVirtualNode): Boolean;

// Helper method to check if Node is the same as the first visible child of Parent.

var
  Run: PVirtualNode;

begin
  // Find first visible child.
  Run := Parent.FirstChild;
  while Assigned(Run) and not (vsVisible in Run.States) do
    Run := Run.NextSibling;

  Result := Assigned(Run) and (Run = Node);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.IsLastVisibleChild(Parent, Node: PVirtualNode): Boolean;

// Helper method to check if Node is the same as the last visible child of Parent.

var
  Run: PVirtualNode;
  
begin
  // Find last visible child.
  Run := Parent.LastChild;
  while Assigned(Run) and not (vsVisible in Run.States) do
    Run := Run.PrevSibling;

  Result := Assigned(Run) and (Run = Node);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.LimitPaintingToArea(Canvas: TCanvas; ClipRect: TRect; VisibleRegion: HRGN = 0);

// Limits further painting onto the given canvas to the given rectangle.
// VisibleRegion is an optional region which can be used to limit drawing further.

var
  ClipRegion: HRGN;

begin
  // Regions expect their coordinates in device coordinates, hence we have to transform the region rectangle.
  LPtoDP(Canvas.Handle, ClipRect, 2);
  ClipRegion := CreateRectRgnIndirect(ClipRect);
  if VisibleRegion <> 0 then
    CombineRgn(ClipRegion, ClipRegion, VisibleRegion, RGN_AND);
  SelectClipRgn(Canvas.Handle, ClipRegion);
  DeleteObject(ClipRegion);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.MakeNewNode: PVirtualNode;

var
  Size: Cardinal;

begin
  Size := TreeNodeSize;
  if not (csDesigning in ComponentState) then
  begin
    // Make sure FNodeDataSize is valid.
    if FNodeDataSize = -1 then
      ValidateNodeDataSize(FNodeDataSize);

    // Take record alignment into account.
    Inc(Size, FNodeDataSize);
  end;

  Result := AllocMem(Size + FTotalInternalDataSize);

  // Fill in some default values.
  with Result^ do
  begin
    TotalCount := 1;
    TotalHeight := FDefaultNodeHeight;
    NodeHeight := FDefaultNodeHeight;
    States := [vsVisible];
    Align := 50;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.OriginalWMNCPaint(DC: HDC);

// Unfortunately, the VCL does a bad job regarding non-client area painting in TWinControl to paint a window's bevel
// which results often in heavy flickering. This method is a copy of TWinControl.WMNCPaintHandler adjusted to take
// the passed update region into account (actually, this happens already in the WMNCPaint).
// Since the advent of themes this method also draws the theme border.

const
  InnerStyles: array[TBevelCut] of Integer = (0, BDR_SUNKENINNER, BDR_RAISEDINNER, 0);
  OuterStyles: array[TBevelCut] of Integer = (0, BDR_SUNKENOUTER, BDR_RAISEDOUTER, 0);
  EdgeStyles: array[TBevelKind] of Integer = (0, 0, BF_SOFT, BF_FLAT);
  Ctl3DStyles: array[Boolean] of Integer = (BF_MONO, 0);

var
  RC, RW: TRect;
  EdgeSize: Integer;
  Styles: Integer;
  HasClientEdge: Boolean;

begin
  // Determine outer rectangle to draw.
  RC := Rect(0, 0, Width, Height);
  Styles := GetWindowLong(Handle, GWL_EXSTYLE);
  HasClientEdge := (Styles and WS_EX_CLIENTEDGE) <> 0;

  // Draw control frame first
  if HasClientEdge then
  begin
    if tsUseThemes in FStates then
    begin
      ExcludeClipRect(DC, RC.Left + 2, RC.Top + 2, RC.Right - 2, RC.Bottom - 2);
      DrawThemeBackground(FTreeTheme, DC, TVP_TREEITEM, TREIS_NORMAL, RC, nil);
    end;
    InflateRect(RC, -2, -2);
  end;

  if (BevelKind <> bkNone) or (BorderWidth > 0) then
  begin
    Styles := GetWindowLong(Handle, GWL_STYLE);
    if (Styles and WS_BORDER) <> 0 then
      InflateRect(RC, -1, -1);
    if (Styles and WS_THICKFRAME) <> 0 then
      InflateRect(RC, -3, -3);

    RW := RC;

    if BevelKind <> bkNone then
    begin
      DrawEdge(DC, RC, InnerStyles[BevelInner] or OuterStyles[BevelOuter], Byte(BevelEdges) or EdgeStyles[BevelKind] or
        Ctl3DStyles[Ctl3D]);

      EdgeSize := 0;
      if BevelInner <> bvNone then
        Inc(EdgeSize, BevelWidth);
      if BevelOuter <> bvNone then
        Inc(EdgeSize, BevelWidth);
      with RC do
      begin
        if beLeft in BevelEdges then
          Inc(Left, EdgeSize);
        if beTop in BevelEdges then
          Inc(Top, EdgeSize);
        if beRight in BevelEdges then
          Dec(Right, EdgeSize);
        if beBottom in BevelEdges then
          Dec(Bottom, EdgeSize);
      end;
    end;
    
    // Repaint only the part in the original clipping region and not yet drawn parts.
    IntersectClipRect(DC, RC.Left, RC.Top, RC.Right, RC.Bottom);

    // Determine inner rectangle to exclude (RC corresponds then to the client area).
    InflateRect(RC, -BorderWidth, -BorderWidth);

    // Remove the inner rectangle.
    ExcludeClipRect(DC, RC.Left, RC.Top, RC.Right, RC.Bottom);

    // Erase parts not drawn.
    Brush.Color := FColors.BorderColor;
    Windows.FillRect(DC, RW, Brush.Handle);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.PackArray(TheArray: TNodeArray; Count: Integer): Integer; assembler;

// Removes all entries from the selection array which are no longer in use. The selection array must be sorted for this
// algo to work. Values which must be removed are marked with bit 0 (LSB) set. This little trick works because memory
// is always allocated DWORD aligned. Since the selection array must be sorted while determining the entries to be
// removed it is much more efficient to increment the entry in question instead of setting it to nil (which would break
// the ordered appearance of the list).
//
// On enter EAX contains self reference, EDX the address to TheArray and ECX Count
// The returned value is the number of remaining entries in the array, so the caller can reallocate (shorten)
// the selection array if needed or -1 if nothing needs to be changed.

asm
        PUSH    EBX
        PUSH    EDI
        PUSH    ESI
        MOV     ESI, EDX
        MOV     EDX, -1
        JCXZ    @@Finish               // Empty list?
        INC     EDX                    // init remaining entries counter
        MOV     EDI, ESI               // source and destination point to the list memory
        MOV     EBX, 1                 // use a register instead of immediate operant to check against
@@PreScan:
        TEST    [ESI], EBX             // do the fastest scan possible to find the first entry
                                       // which must be removed
        JNZ     @@DoMainLoop
        INC     EDX
        ADD     ESI, 4
        DEC     ECX
        JNZ     @@PreScan
        JMP     @@Finish

@@DoMainLoop:
        MOV     EDI, ESI
@@MainLoop:
        TEST    [ESI], EBX             // odd entry?
        JNE     @@Skip                 // yes, so skip this one
        MOVSD                          // else move the entry to new location
        INC     EDX                    // count the moved entries
        DEC     ECX
        JNZ     @@MainLoop             // do it until all entries are processed
        JMP     @@Finish

@@Skip:
        ADD     ESI, 4                 // point to the next entry
        DEC     ECX
        JNZ     @@MainLoop             // do it until all entries are processed
@@Finish:
        MOV     EAX, EDX               // prepare return value
        POP     ESI
        POP     EDI
        POP     EBX
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.PaintCheckImage(const PaintInfo: TVTPaintInfo);

var
  ForegroundColor: COLORREF;
  R: TRect;

begin
  with PaintInfo, ImageInfo[iiCheck] do
  begin
    if (tsUseThemes in FStates) and (FCheckImageKind <> ckCustom) then
    begin
      R := Rect(XPos - 1, YPos, XPos + 16, YPos + 16);
      case Index of
        0..8: // radio buttons
          DrawThemeBackground(FButtonTheme, Canvas.Handle, BP_RADIOBUTTON, Index, R, nil);
        9..20: // check boxes
          DrawThemeBackground(FButtonTheme, Canvas.Handle, BP_CHECKBOX, Index - 8, R, nil);
        21..24: // buttons
          begin
            DrawThemeBackground(FButtonTheme, Canvas.Handle, BP_PUSHBUTTON, Index - 20, R, nil);
            UtilityImages.Draw(Canvas, XPos - 1, YPos, 4);
          end;
      end;
    end
    else
      with FCheckImages do
      begin
        if (vsSelected in Node.States) and not Ghosted then
        begin
          if Focused or (toPopupMode in FOptions.FPaintOptions) then
            ForegroundColor := ColorToRGB(FColors.FocusedSelectionColor)
          else
            ForegroundColor := ColorToRGB(FColors.UnfocusedSelectionColor);
        end
        else
          ForegroundColor := GetRGBColor(BlendColor);

          ImageList_DrawEx(Handle, Index, Canvas.Handle, XPos, YPos, 0, 0, GetRGBColor(BkColor), ForegroundColor,
            ILD_TRANSPARENT);
      end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.PaintImage(const PaintInfo: TVTPaintInfo; ImageInfoIndex: TVTImageInfoIndex;
  Images: TImageList; DoOverlay: Boolean);

const
  Style: array[TImageType] of Cardinal = (0, ILD_MASK);

var
  OverlayImage: Integer;
  OverlayGhosted: Boolean;
  ExtraStyle: Cardinal;
  ForegroundColor: COLORREF;

begin
  with PaintInfo, ImageInfo[ImageInfoIndex], Images do
  begin
    if (vsSelected in Node.States) and not Ghosted then
    begin
      if Focused or (toPopupMode in FOptions.FPaintOptions) then
        ForegroundColor := ColorToRGB(FColors.FocusedSelectionColor)
      else
        ForegroundColor := ColorToRGB(FColors.UnfocusedSelectionColor);
    end
    else
      ForegroundColor := GetRGBColor(BlendColor);

    // Since the overlay image must be specified together with the image to draw
    // it is meaningfull to retrieve it in advance.
    if DoOverlay then
      OverlayImage := GetImageIndex(PaintInfo.Node, ikOverlay, PaintInfo.Column, OverlayGhosted)
    else
      OverlayImage := -1;
    if (vsDisabled in Node.States) or not Enabled then
    begin
      // The internal handling for disabled images in TImageList destroys the forground color on Windows API level.
      // Hence the canvas does not recognize the change and we have to restore the color manually.
      ForegroundColor := ColorToRGB(Canvas.Font.Color);

      // If the tree or the current node is disabled then let the VCL draw the image as it already
      // contains code to convert the image to the system colors.
      if OverlayImage > -1 then
        Images.DrawOverlay(Canvas, XPos, YPos, Index, OverlayImage, False)
      else
        Images.Draw(Canvas, XPos, YPos, Index, False);

      SetTextColor(Canvas.Handle, ForegroundColor);
    end
    else
    begin
      if OverlayImage > -1 then
        ExtraStyle := ILD_TRANSPARENT or ILD_OVERLAYMASK and IndexToOverlayMask(OverlayImage + 1)
      else
        ExtraStyle := ILD_TRANSPARENT;

      // Blend image if enabled and the tree has the focus and it is ghosted...
      if (toUseBlendedImages in FOptions.FPaintOptions) and Focused and (Ghosted or
        // ... or it is not the check image and the node is selected (but selection is not for the entire row)...
        ((vsSelected in Node.States) and 
        not (toFullRowSelect in FOptions.FSelectionOptions) and
        not (toGridExtensions in FOptions.FMiscOptions)) or
        // ... or if cut is pending and the node is in the cut set.
        ((vsCutOrCopy in Node.States) and (tsCutPending in FStates))) then
        ExtraStyle := ExtraStyle or ILD_BLEND50;

      ImageList_DrawEx(Handle, Index, Canvas.Handle, XPos, YPos, 0, 0, GetRGBColor(BkColor), ForegroundColor,
        Style[ImageType] or ExtraStyle);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.PaintNodeButton(Canvas: TCanvas; Node: PVirtualNode; const R: TRect; ButtonX,
  ButtonY: Integer; BidiMode: TBiDiMode);

var
  Bitmap: TBitmap;
  XPos: Integer;

begin
  if vsExpanded in Node.States then
    Bitmap := FMinusBM
  else
    Bitmap := FPlusBM;

  // Draw the node's plus/minus button according to the directionality.
  if BidiMode = bdLeftToRight then
    XPos := R.Left + ButtonX
  else
    XPos := R.Right - ButtonX - Bitmap.Width;

  // Need to draw this masked.
  Canvas.Draw(XPos, R.Top + ButtonY, Bitmap);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.PaintTreeLines(const PaintInfo: TVTPaintInfo; VAlignment, IndentSize: Integer;
  LineImage: TLineImage);

var
  I: Integer;
  XPos,
  Offset: Integer;
  NewStyles: TLineImage;

begin
  NewStyles := nil;
   
  with PaintInfo do
  begin
    if BidiMode = bdLeftToRight then
    begin
      XPos := CellRect.Left;
      Offset := FIndent;
    end
    else
    begin
      Offset := -Integer(FIndent);
      XPos := CellRect.Right + Offset;
    end;

    case FLineMode of
      lmBands:
        if poGridLines in PaintInfo.PaintOptions then
        begin
          // Convert the line images in correct bands.
          SetLength(NewStyles, Length(LineImage));
          for I := IndentSize - 1 downto 0 do
          begin
            if vsExpanded in Node.States then
              NewStyles[I] := ltLeft
            else
              case LineImage[I] of
                ltRight,
                ltBottomRight,
                ltTopDownRight,
                ltTopRight:
                  NewStyles[I] := ltLeftBottom;
                ltNone:
                  // Have to take over the image to the right of this one. A no line entry can never appear as
                  // last entry so I don't need an end check here.
                  if LineImage[I + 1] in [ltNone, ltTopRight] then
                    NewStyles[I] := NewStyles[I + 1]
                  else
                    NewStyles[I] := ltLeft;
                ltTopDown:
                  // Have to check the image to the right of this one. A top down line can never appear as
                  // last entry so I don't need an end check here.
                  if LineImage[I + 1] in [ltNone, ltTopRight] then
                    NewStyles[I] := NewStyles[I + 1]
                  else
                    NewStyles[I] := ltLeft;
              end;
          end;

          PaintInfo.Canvas.Font.Color := FColors.GridLineColor;
          for I := 0 to IndentSize - 1 do
          begin
            DrawLineImage(PaintInfo, XPos, CellRect.Top, Node.NodeHeight - 1, VAlignment, NewStyles[I],
              BidiMode <> bdLeftToRight);
            Inc(XPos, Offset);
          end;
        end;
    else // lmNormal
      PaintInfo.Canvas.Font.Color := FColors.TreeLineColor;
      for I := 0 to IndentSize - 1 do
      begin
        DrawLineImage(PaintInfo, XPos, CellRect.Top, Node.NodeHeight, VAlignment, LineImage[I],
          BidiMode <> bdLeftToRight);
        Inc(XPos, Offset);
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.PrepareBitmaps(NeedButtons, NeedLines: Boolean);

// initializes the contents of the internal bitmaps

const
  LineBitsDotted: array [0..8] of Word = ($55, $AA, $55, $AA, $55, $AA, $55, $AA, $55);
  LineBitsSolid: array [0..7] of Word = (0, 0, 0, 0, 0, 0, 0, 0);

var
  PatternBitmap: HBITMAP;
  Bits: Pointer;
  
begin
  if NeedButtons then
  begin
    with FMinusBM, Canvas do
    begin
      // box is always of odd size
      Width := 9;
      Height := Width;
      Transparent := True;
      TransparentColor := clFuchsia;
      Brush.Color := clFuchsia;
      FillRect(Rect(0, 0, Width, Height));
      if FButtonStyle = bsTriangle then
      begin
        Brush.Color := clBlack;
        Pen.Color := clBlack;
        Polygon([Point(0, 2), Point(8, 2), Point(4, 6)]);
      end
      else                                                                
      begin
        // Button style is rectangular. Now ButtonFillMode determines how to fill the interior.
        if FButtonFillMode in [fmTreeColor, fmWindowColor, fmTransparent] then
        begin
          case FButtonFillMode of
            fmTreeColor:
              Brush.Color := Self.Color;
            fmWindowColor:
              Brush.Color := clWindow;
          end;
          Pen.Color := FColors.TreeLineColor;
          Rectangle(0, 0, Width, Height);
          Pen.Color := Self.Font.Color;
          MoveTo(2, Width div 2);
          LineTo(Width - 2 , Width div 2);
        end
        else
          FMinusBM.Handle := LoadBitmap(HInstance, 'VT_XPBUTTONMINUS');
      end;
    end;

    with FPlusBM, Canvas do
    begin                                 
      Width := 9;
      Height := Width;
      Transparent := True;
      TransparentColor := clFuchsia;
      Brush.Color := clFuchsia;
      FillRect(Rect(0, 0, Width, Height));
      if FButtonStyle = bsTriangle then
      begin
        Brush.Color := clBlack;
        Pen.Color := clBlack;
        Polygon([Point(2, 0), Point(6, 4), Point(2, 8)]);
      end
      else
      begin
        // Button style is rectangular. Now ButtonFillMode determines how to fill the interior.
        if FButtonFillMode in [fmTreeColor, fmWindowColor, fmTransparent] then
        begin
          case FButtonFillMode of
            fmTreeColor:
              Brush.Color := Self.Color;
            fmWindowColor:
              Brush.Color := clWindow;
          end;

          Pen.Color := FColors.TreeLineColor;
          Rectangle(0, 0, Width, Height);
          Pen.Color := Self.Font.Color;
          MoveTo(2, Width div 2);
          LineTo(Width - 2 , Width div 2);
          MoveTo(Width div 2, 2);
          LineTo(Width div 2, Width - 2);
        end
        else
          FPlusBM.Handle := LoadBitmap(HInstance, 'VT_XPBUTTONPLUS');
      end;
    end;

    // Overwrite glyph images if theme is active.
    if FTreeTheme > 0 then
    begin
      DrawThemeBackground(FTreeTheme, FPlusBM.Canvas.Handle, TVP_GLYPH, GLPS_CLOSED, Rect(0, 0, 9, 9), nil);
      DrawThemeBackground(FTreeTheme, FMinusBM.Canvas.Handle, TVP_GLYPH, GLPS_OPENED, Rect(0, 0, 9, 9), nil);
    end;
  end;

  if NeedLines then
  begin
    if FDottedBrush <> 0 then
      DeleteObject(FDottedBrush);

    case FLineStyle of
      lsDotted:
        Bits := @LineBitsDotted;
      lsSolid:
        Bits := @LineBitsSolid;
    else // lsCustomStyle
      Bits := @LineBitsDotted;
      DoGetLineStyle(Bits);
    end;
    PatternBitmap := CreateBitmap(8, 8, 1, 1, Bits);
    FDottedBrush := CreatePatternBrush(PatternBitmap);
    DeleteObject(PatternBitmap);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.PrepareCell(var PaintInfo: TVTPaintInfo);

// This method is called immediately before a cell's content is drawn und is responsible to paint selection colors etc.

var
  TextColorBackup,
  BackColorBackup: COLORREF;
  InnerRect: TRect;

begin
  with PaintInfo, Canvas do
  begin
    InnerRect := ContentRect;

    // Fill cell background if its color differs from tree background.
    with FHeader.FColumns do
      if poColumnColor in PaintOptions then
      begin
        Brush.Color := Items[Column].Color;
        FillRect(CellRect);
      end;

    // Let the application customize the cell background.
    DoBeforeCellPaint(Canvas, Node, Column, CellRect);

    if (Column = FFocusedColumn) or (toFullRowSelect in FOptions.FSelectionOptions) then
    begin
      // The selection rectangle depends on alignment.
      if not (toGridExtensions in FOptions.FMiscOptions) then
      begin
        case Alignment of
          taLeftJustify:
            with InnerRect do
              if Left + NodeWidth < Right then
                Right := Left + NodeWidth;
          taCenter:
            with InnerRect do
              if (Right - Left) > NodeWidth then
              begin
                Left := (Left + Right - NodeWidth) div 2;
                Right := Left + NodeWidth;
              end;
          taRightJustify:
            with InnerRect do
              if (Right - Left) > NodeWidth then
                Left := Right - NodeWidth;
        end;
      end;

      // Fill the selection rectangle.
      if poDrawSelection in PaintOptions then
      begin
        if Node = FDropTargetNode then
        begin
          if (FLastDropMode = dmOnNode) or (vsSelected in Node.States) then
          begin
            Brush.Color := FColors.DropTargetColor;
            Pen.Color := FColors.DropTargetBorderColor;

            if (toGridExtensions in FOptions.FMiscOptions) or
              (toFullRowSelect in FOptions.FSelectionOptions) then
              InnerRect := CellRect;
            if not IsRectEmpty(InnerRect) then
              with InnerRect do
                RoundRect(Left, Top, Right, Bottom, FSelectionCurveRadius, FSelectionCurveRadius);
          end
          else
          begin
            Brush.Style := bsClear;
          end;
        end
        else
          if vsSelected in Node.States then
          begin
            if Focused or (toPopupMode in FOptions.FPaintOptions) then
            begin
              Brush.Color := FColors.FocusedSelectionColor;
              Pen.Color := FColors.FocusedSelectionBorderColor;
            end
            else
            begin
              Brush.Color := FColors.UnfocusedSelectionColor;
              Pen.Color := FColors.UnfocusedSelectionBorderColor;
            end;

            if (toGridExtensions in FOptions.FMiscOptions) or (toFullRowSelect in FOptions.FSelectionOptions) then
              InnerRect := CellRect;
            if not IsRectEmpty(InnerRect) then
              with InnerRect do
                RoundRect(Left, Top, Right, Bottom, FSelectionCurveRadius, FSelectionCurveRadius);
          end;
      end;

      // draw focus rect
      if (poDrawFocusRect in PaintOptions) and (Column = FFocusedColumn) and
        (Focused or (toPopupMode in FOptions.FPaintOptions)) and (FFocusedNode = Node) then
      begin
        TextColorBackup := GetTextColor(Handle);
        SetTextColor(Handle, $FFFFFF);
        BackColorBackup := GetBkColor(Handle);
        SetBkColor(Handle, 0);

        if toGridExtensions in FOptions.FMiscOptions then
          Windows.DrawFocusRect(Handle, CellRect)
        else
          Windows.DrawFocusRect(Handle, InnerRect);

        SetTextColor(Handle, TextColorBackup);
        SetBkColor(Handle, BackColorBackup);
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

type
  TOldVTOption = (voAcceptOLEDrop, voAnimatedToggle, voAutoDropExpand, voAutoExpand, voAutoScroll,
    voAutoSort, voAutoSpanColumns, voAutoTristateTracking, voCheckSupport, voDisableDrawSelection, voEditable,
    voExtendedFocus, voFullRowSelect, voGridExtensions, voHideFocusRect, voHideSelection, voHotTrack, voInitOnSave,
    voLevelSelectConstraint, voMiddleClickSelect, voMultiSelect, voRightClickSelect, voPopupMode, voShowBackground,
    voShowButtons, voShowDropmark, voShowHorzGridLines, voShowRoot, voShowTreeLines, voShowVertGridLines,
    voSiblingSelectConstraint, voToggleOnDblClick);

const
  OptionMap: array[TOldVTOption] of Integer = (
    Ord(toAcceptOLEDrop), Ord(toAnimatedToggle), Ord(toAutoDropExpand), Ord(toAutoExpand), Ord(toAutoScroll),
    Ord(toAutoSort), Ord(toAutoSpanColumns), Ord(toAutoTristateTracking), Ord(toCheckSupport), Ord(toDisableDrawSelection),
    Ord(toEditable), Ord(toExtendedFocus), Ord(toFullRowSelect), Ord(toGridExtensions), Ord(toHideFocusRect),
    Ord(toHideSelection), Ord(toHotTrack), Ord(toInitOnSave), Ord(toLevelSelectConstraint), Ord(toMiddleClickSelect),
    Ord(toMultiSelect), Ord(toRightClickSelect), Ord(toPopupMode), Ord(toShowBackground),
    Ord(toShowButtons), Ord(toShowDropmark), Ord(toShowHorzGridLines), Ord(toShowRoot), Ord(toShowTreeLines),
    Ord(toShowVertGridLines), Ord(toSiblingSelectConstraint), Ord(toToggleOnDblClick)
  );

procedure TBaseVirtualTree.ReadOldOptions(Reader: TReader);

// Migration helper routine to silently convert forms containing the old tree options member into the new
// sub-options structure.

var
  OldOption: TOldVTOption;
  EnumName: string;

begin
  // If we are at design time currently then let the designer know we changed something.
  UpdateDesigner;

  // It should never happen at this place that there is something different than the old set.
  if Reader.ReadValue = vaSet then
  begin
    // Remove all default values set by the constructor.
    FOptions.AnimationOptions := [];
    FOptions.AutoOptions := [];
    FOptions.MiscOptions := [];
    FOptions.PaintOptions := [];
    FOptions.SelectionOptions := [];

    while True do
    begin
      // Sets are stored with their members as simple strings. Read them one by one and map them to the new option
      // in the correct sub-option set.
      EnumName := Reader.ReadStr;
      if EnumName = '' then
        Break;
      OldOption := TOldVTOption(GetEnumValue(TypeInfo(TOldVTOption), EnumName));
      case OldOption of
        voAcceptOLEDrop, voCheckSupport, voEditable, voGridExtensions, voInitOnSave, voToggleOnDblClick:
          FOptions.MiscOptions := FOptions.FMiscOptions + [TVTMiscOption(OptionMap[OldOption])];
        voAnimatedToggle:
          FOptions.AnimationOptions := FOptions.FAnimationOptions + [TVTAnimationOption(OptionMap[OldOption])];
        voAutoDropExpand, voAutoExpand, voAutoScroll, voAutoSort, voAutoSpanColumns, voAutoTristateTracking:
          FOptions.AutoOptions := FOptions.FAutoOptions + [TVTAutoOption(OptionMap[OldOption])];
        voDisableDrawSelection, voExtendedFocus, voFullRowSelect, voLevelSelectConstraint,
        voMiddleClickSelect, voMultiSelect, voRightClickSelect, voSiblingSelectConstraint:
          FOptions.SelectionOptions := FOptions.FSelectionOptions + [TVTSelectionOption(OptionMap[OldOption])];
        voHideFocusRect, voHideSelection, voHotTrack, voPopupMode, voShowBackground, voShowButtons,
        voShowDropmark, voShowHorzGridLines, voShowRoot, voShowTreeLines, voShowVertGridLines:
          FOptions.PaintOptions := FOptions.FPaintOptions + [TVTPaintOption(OptionMap[OldOption])];
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.RedirectFontChangeEvent(Canvas: TCanvas);

begin
  if @Canvas.Font.OnChange <> @FOldFontChange then
  begin
    FOldFontChange := Canvas.Font.OnChange;
    Canvas.Font.OnChange := FontChanged;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.RestoreFontChangeEvent(Canvas: TCanvas);

begin
  Canvas.Font.OnChange := FOldFontChange;
  FOldFontChange := nil;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetAlignment(const Value: TAlignment);

begin
  if FAlignment <> Value then
  begin
    FAlignment := Value;
    if not (csLoading in ComponentState) then
      Invalidate;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetAnimationDuration(const Value: Cardinal);

begin
  FAnimationDuration := Value;
  if FAnimationDuration = 0 then
    Exclude(FOptions.FAnimationOptions, toAnimatedToggle)
  else
    Include(FOptions.FAnimationOptions, toAnimatedToggle);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetBackground(const Value: TPicture);

begin
  FBackground.Assign(Value);
  Invalidate;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetBackgroundOffset(const Index, Value: Integer);

begin
  case Index of
    0:
      if FBackgroundOffsetX <> Value then
      begin
        FBackgroundOffsetX := Value;
        Invalidate;
      end;
    1:
      if FBackgroundOffsetY <> Value then
      begin
        FBackgroundOffsetY := Value;
        Invalidate;
      end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetBorderStyle(Value: TBorderStyle);

begin
  if FBorderStyle <> Value then
  begin
    FBorderStyle := Value;
    RecreateWnd;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetButtonFillMode(const Value: TVTButtonFillMode);

begin
  if FButtonFillMode <> Value then
  begin
    FButtonFillMode := Value;
    if not (csLoading in ComponentState) then
    begin
      PrepareBitmaps(True, False);
      if HandleAllocated then
        Invalidate;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetButtonStyle(const Value: TVTButtonStyle);

begin
  if FButtonStyle <> Value then
  begin
    FButtonStyle := Value;
    if not (csLoading in ComponentState) then
    begin
      PrepareBitmaps(True, False);
      if HandleAllocated then
        Invalidate;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetCheckImageKind(Value: TCheckImageKind);

begin
  if FCheckImageKind <> Value then
  begin
    FCheckImageKind := Value;
    case Value of
      ckDarkCheck:
        FCheckImages := DarkCheckImages;
      ckLightTick:
        FCheckImages := LightTickImages;
      ckDarkTick:
        FCheckImages := DarkTickImages;
      ckLightCheck:
        FCheckImages := LightCheckImages;
      ckFlat:
        FCheckImages := FlatImages;
      ckXP:
        FCheckImages := XPImages;
    else
      FCheckImages := FCustomCheckImages;
    end;
    if HandleAllocated and (FUpdateCount = 0) and not (csLoading in ComponentState) then
      InvalidateRect(Handle, nil, False);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetCheckState(Node: PVirtualNode; Value: TCheckState);

begin
  if (Node.CheckState <> Value) and not (vsDisabled in Node.States) and DoChecking(Node, Value) then
    DoCheckClick(Node, Value);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetCheckType(Node: PVirtualNode; Value: TCheckType);

begin
  if Node.CheckType <> Value then
  begin
    Node.CheckType := Value;
    Node.CheckState := csUncheckedNormal;
    // For check boxes with tri-state check box parents we have to initialize differently.
    if (Value in [ctCheckBox, ctTriStateCheckBox]) and (Node.Parent <> FRoot) then
    begin
      if not (vsInitialized in Node.Parent.States) then
        InitNode(Node.Parent);
      if (Node.Parent.CheckType = ctTriStateCheckBox) and
        (Node.Parent.CheckState in [csUncheckedNormal, csCheckedNormal]) then
        CheckState[Node] := Node.Parent.CheckState;
    end;
    InvalidateNode(Node);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------
                                         
procedure TBaseVirtualTree.SetChildCount(Node: PVirtualNode; NewChildCount: Cardinal);

// Changes a node's child structure to accomodate the new child count. This is used to add or delete
// child nodes to/from the end of the node's child list. To insert or delete a specific node a separate
// routine is used.

var
  Count: Integer;
  Index: Cardinal;
  Child: PVirtualNode;
  C: Integer;
  NewHeight: Integer;

begin
  if Node = nil then
    Node := FRoot;
    
  if NewChildCount = 0 then
    DeleteChildren(Node)
  else
  begin
    Count := Integer(NewChildCount) - Integer(Node.ChildCount);

    // If nothing changed then do nothing.
    if Count <> 0 then
    begin
      InterruptValidation;

      C := Count;
      NewHeight := 0;
      
      if Count > 0 then
      begin
        // New nodes to add.
        if Assigned(Node.LastChild) then
          Index := Node.LastChild.Index + 1
        else
        begin
          Index := 0;
          Include(Node.States, vsHasChildren);
        end;

        // New nodes are by default always visible, so we don't need to check the visibility.
        while Count > 0 do
        begin
          Child := MakeNewNode;
          Child.Index := Index;
          Child.PrevSibling := Node.LastChild;
          if Assigned(Node.LastChild) then
            Node.LastChild.NextSibling := Child;
          Child.Parent := Node;
          Node.LastChild := Child;
          if Node.FirstChild = nil then
            Node.FirstChild := Child;
          Dec(Count);
          Inc(Index);
          Inc(NewHeight, Child.NodeHeight);
        end;

        if vsExpanded in Node.States then
        begin
          AdjustTotalHeight(Node, NewHeight, True);
          if FullyVisible[Node] then
            Inc(Integer(FVisibleCount), C);
        end;

        AdjustTotalCount(Node, C, True);
        Node.ChildCount := NewChildCount;
        InvalidateCache;
      end
      else
      begin
        // Nodes have to be deleted.
        while Count < 0 do
        begin
          DeleteNode(Node.LastChild);
          Inc(Count);
        end;
      end;

      if FUpdateCount = 0 then
      begin
        ValidateCache;
        UpdateScrollBars(True);
        Invalidate;
      end;

      if Node = FRoot then
        StructureChange(nil, crChildAdded)
      else
        StructureChange(Node, crChildAdded);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetClipboardFormats(const Value: TClipboardFormats);

var
  I: Integer;

begin
  // Add string by string instead doing an Assign or AddStrings because the list may return -1 for
  // invalid entries which cause trouble for the standard implementation.
  FClipboardFormats.Clear;
  for I := 0 to Value.Count - 1 do
    FClipboardFormats.Add(Value[I]);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetColors(const Value: TVTColors);

begin
  FColors.Assign(Value);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetCustomCheckImages(const Value: TImageList);

begin
  if FCustomCheckImages <> Value then
  begin
    if Assigned(FCustomCheckImages) then
    begin
      FCustomCheckImages.UnRegisterChanges(FCustomCheckChangeLink);
      // Reset the internal check image list reference too, if necessary.
      if FCheckImages = FCustomCheckImages then
        FCheckImages := nil;
    end;
    FCustomCheckImages := Value;
    if Assigned(FCustomCheckImages) then
      FCustomCheckImages.RegisterChanges(FCustomCheckChangeLink);
    // Check if currently custom check images are active.
    if FCheckImageKind = ckCustom then
      FCheckImages := Value;
    if not (csLoading in ComponentState) then
      Invalidate;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetDisabled(Node: PVirtualNode; Value: Boolean);

begin
  if Assigned(Node) and (Value xor (vsDisabled in Node.States)) then
  begin
    if Value then
      Include(Node.States, vsDisabled)
    else
      Exclude(Node.States, vsDisabled);

    if FUpdateCount = 0 then
      InvalidateNode(Node);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetExpanded(Node: PVirtualNode; Value: Boolean);

begin
  if Assigned(Node) and (Node <> FRoot) and (Value xor (vsExpanded in Node.States)) then
    ToggleNode(Node);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetFocusedColumn(Value: Integer);

begin
  if (FFocusedColumn <> Value) and
     DoFocusChanging(FFocusedNode, FFocusedNode, FFocusedColumn, Value) then
  begin
    CancelEditNode;
    FFocusedColumn := Value;
    if Assigned(FFocusedNode) then
    begin
      ScrollIntoView(FFocusedNode, True);
      InvalidateNode(FFocusedNode);
    end;

    DoFocusChange(FFocusedNode, FFocusedColumn);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetFocusedNode(Value: PVirtualNode);

var
  WasDifferent: Boolean;

begin
  WasDifferent := Value <> FFocusedNode;
  DoFocusNode(Value, True);
  // Do change event only if there was actually a change.
  if WasDifferent and (FFocusedNode = Value) then
    DoFocusChange(FFocusedNode, FFocusedColumn);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetFullyVisible(Node: PVirtualNode; Value: Boolean);

// This method ensures that a node is visible and all its parent nodes are expanded and also visible
// if Value is True. Otherwise the visibility flag of the node is reset but the expand state
// of the parent nodes stays untouched.

begin
  Assert(Assigned(Node) and (Node <> FRoot), 'Invalid parameter');

  IsVisible[Node] := Value;
  if Value then
  begin
    repeat
      Node := Node.Parent;
      if Node = FRoot then
        Break;
      if not (vsExpanded in Node.States) then
        ToggleNode(Node);
      if not (vsVisible in Node.States) then
        IsVisible[Node] := True;
    until False;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetHasChildren(Node: PVirtualNode; Value: Boolean);

begin
  if Assigned(Node) then
  begin
    if Value then
      Include(Node.States, vsHasChildren)
    else
    begin
      Exclude(Node.States, vsHasChildren);
      DeleteChildren(Node);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetHeader(const Value: TVTHeader);

begin
  FHeader.Assign(Value);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetImages(const Value: TImageList);

begin
  if FImages <> Value then
  begin
    if Assigned(FImages) then
      FImages.UnRegisterChanges(FImageChangeLink);
    FImages := Value;
    if Assigned(FImages) then
      FImages.RegisterChanges(FImageChangeLink);
    if not (csLoading in ComponentState) then
      Invalidate;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetIndent(Value: Cardinal);

begin
  if FIndent <> Value then
  begin
    FIndent := Value;
    if not (csLoading in ComponentState) and (FUpdateCount = 0) and HandleAllocated then
    begin
      UpdateScrollBars(True);
      Invalidate;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetItemHeight(Value: Cardinal);

begin
  if Value <= 0 then
    Value := 18;
  if FDefaultNodeHeight <> Value then
  begin
    Inc(Integer(FRoot.TotalHeight), Integer(Value) - Integer(FDefaultNodeHeight));
    Inc(SmallInt(FRoot.NodeHeight), Integer(Value) - Integer(FDefaultNodeHeight));
    FDefaultNodeHeight := Value;
    InvalidateCache;
    if (FUpdateCount = 0) and HandleAllocated and not (csLoading in ComponentState) then
    begin
      ValidateCache;
      UpdateScrollBars(True);
      ScrollIntoView(FFocusedNode, True);
      Invalidate;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetLineMode(const Value: TVTLineMode);

begin
  if FLineMode <> Value then
  begin
    FLineMode := Value;
    if HandleAllocated and not (csLoading in ComponentState) then
      Invalidate;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetLineStyle(const Value: TVTLineStyle);

begin
  if FLineStyle <> Value then
  begin
    FLineStyle := Value;
    if not (csLoading in ComponentState) then
    begin
      PrepareBitmaps(False, True);
      if HandleAllocated then
        Invalidate;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetMargin(Value: Integer);

begin
  if FMargin <> Value then
  begin
    FMargin := Value;
    if HandleAllocated and not (csLoading in ComponentState) then
      Invalidate;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetNodeAlignment(const Value: TVTNodeAlignment);

begin
  if FNodeAlignment <> Value then
  begin
    FNodeAlignment := Value;
    if HandleAllocated and not (csReading in ComponentState) then
      Invalidate;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetNodeDataSize(Value: Integer);

var
  LastRootCount: Cardinal;

begin
  if Value < -1 then
    Value := -1;
  if FNodeDataSize <> Value then
  begin
    FNodeDataSize := Value;
    if not (csLoading in ComponentState) and not (csDesigning in ComponentState) then
    begin
      LastRootCount := FRoot.ChildCount;
      Clear;
      SetRootNodeCount(LastRootCount);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetNodeHeight(Node: PVirtualNode; Value: Cardinal);

var
  Difference: Integer;

begin
  if Assigned(Node) and (Node <> FRoot) and (Node.NodeHeight <> Value) then
  begin
    Difference := Integer(Value) - Integer(Node.NodeHeight);
    Node.NodeHeight := Value;
    AdjustTotalHeight(Node, Difference, True);
    if FullyVisible[Node] then
    begin
      ValidateCache;
      if FUpdateCount = 0 then
      begin
        InvalidateToBottom(Node);
        UpdateScrollBars(True);
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetOffsetX(const Value: Integer);

begin
  DoSetOffsetXY(Point(Value, FOffsetY), DefaultScrollUpdateFlags);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetOffsetXY(const Value: TPoint);

begin
  DoSetOffsetXY(Value, DefaultScrollUpdateFlags);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetOffsetY(const Value: Integer);

begin
  DoSetOffsetXY(Point(FOffsetX, Value), DefaultScrollUpdateFlags);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetOptions(const Value: TCustomVirtualTreeOptions);

begin
  FOptions.Assign(Value);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetRootNodeCount(Value: Cardinal);

begin
  // Don't set the root node count until all other properties (in particular the OnInitNode event) have been set.
  if csLoading in ComponentState then
  begin
    FRoot.ChildCount := Value;
    Include(FStates, tsNeedRootCountUpdate);
  end
  else
    if FRoot.ChildCount <> Value then
    begin
      BeginUpdate;
      InterruptValidation;
      SetChildCount(FRoot, Value);
      EndUpdate;
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetScrollBarOptions(Value: TScrollBarOptions);

begin
  FScrollBarOptions.Assign(Value);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetSearchOption(const Value: TVTIncrementalSearch);

begin
  if FIncrementalSearch <> Value then
  begin
    FIncrementalSearch := Value;
    if FIncrementalSearch = isNone then
    begin
      StopTimer(SearchTimer);
      FSearchBuffer := '';
      FLastSearchNode := nil;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetSelected(Node: PVirtualNode; Value: Boolean);

begin
  if Assigned(Node) and (Node <> FRoot) and (Value xor (vsSelected in Node.States)) then
  begin
    if Value then
    begin
      if FSelectionCount = 0 then
        FRangeAnchor := Node
      else
        if not (toMultiSelect in FOptions.FSelectionOptions) then
          ClearSelection;

      AddToSelection(Node);

      // Make sure there is a valid column selected (if there are columns at all).
      if ((FFocusedColumn < 0) or not (coVisible in FHeader.Columns[FFocusedColumn].Options)) and
        (FHeader.MainColumn > NoColumn) then
        if coVisible in FHeader.Columns[FHeader.MainColumn].Options then
          FFocusedColumn := FHeader.MainColumn
        else
          FFocusedColumn := FHeader.Columns.GetFirstVisibleColumn;
      if FRangeAnchor = nil then
        FRangeAnchor := Node;
    end
    else
    begin
      RemoveFromSelection(Node);
      if FSelectionCount = 0 then
        ResetRangeAnchor;
    end;
    if FullyVisible[Node] then
      InvalidateNode(Node);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetSelectionCurveRadius(const Value: Cardinal);

begin
  if FSelectionCurveRadius <> Value then
  begin
    FSelectionCurveRadius := Value;
    if HandleAllocated and not (csLoading in ComponentState) then
      Invalidate;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetStateImages(const Value: TImageList);

begin
  if FStateImages <> Value then
  begin
    if Assigned(FStateImages) then
      FStateImages.UnRegisterChanges(FStateChangeLink);
    FStateImages := Value;
    if Assigned(FStateImages) then
      FStateImages.RegisterChanges(FStateChangeLink);
    if HandleAllocated and not (csLoading in ComponentState) then
      Invalidate;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetTextMargin(Value: Integer);

begin
  if FTextMargin <> Value then
  begin
    FTextMargin := Value;
    if not (csLoading in ComponentState) then
      Invalidate;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetTopNode(Node: PVirtualNode);

var
  R: TRect;
  Run: PVirtualNode;

begin
  if Assigned(Node) then
  begin
    // make sure all parents of the node are expanded
    Run := Node.Parent;
    while Run <> FRoot do
    begin
      if not (vsExpanded in Run.States) then
        ToggleNode(Run);
      Run := Run.Parent;
    end;
    R := GetDisplayRect(Node, FHeader.MainColumn, True);
    SetOffsetY(FOffsetY - R.Top);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetUpdateState(Updating: Boolean);

begin
  // The check for visibility is necessary otherwise the tree is automatically shown when
  // updating is allowed. As this happens internally the VCL does not get notified and
  // still assumes the control is hidden. This results in weird "cannot focus invisble control" errors.
  if Visible and HandleAllocated then
    SendMessage(Handle, WM_SETREDRAW, Ord(not Updating), 0);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetVerticalAlignment(Node: PVirtualNode; Value: Byte);

begin
  if Value > 100 then
    Value := 100;
  if Node.Align <> Value then
  begin
    Node.Align := Value;
    if FullyVisible[Node] then
      InvalidateNode(Node);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetVisible(Node: PVirtualNode; Value: Boolean);

// Sets the visibility style of the given node according to Value.

var
  NeedUpdate: Boolean;
  Run: PVirtualNode;
  
begin
  Assert(Assigned(Node) and (Node <> FRoot), 'Invalid parameter.');

  if Value <> (vsVisible in Node.States) then
  begin
    NeedUpdate := False;
    if Value then
    begin
      Include(Node.States, vsVisible);
      if vsExpanded in Node.Parent.States then
        AdjustTotalHeight(Node.Parent, Node.TotalHeight, True);
      if VisiblePath[Node] then
      begin
        Inc(FVisibleCount);
        NeedUpdate := True;
      end;
      
      // Update the hidden children flag of the parent.
      // Since this node is now visible we simply have to remove the flag.
      Exclude(Node.Parent.States, vsAllChildrenHidden);
    end
    else
    begin
      Exclude(Node.States, vsVisible);
      if vsExpanded in Node.Parent.States then
        AdjustTotalHeight(Node.Parent, -Integer(Node.TotalHeight), True);
      if VisiblePath[Node] then
      begin
        Dec(FVisibleCount);
        NeedUpdate := True;
      end;

      // Update the hidden children flag of the parent.
      // Iterate through all siblings and stop when one visible is found.
      Run := Node.Parent.FirstChild;
      while Assigned(Run) and not (vsVisible in Run.States) do
        Run := Run.NextSibling;
      if Assigned(Run) then
        Exclude(Node.Parent.States, vsAllChildrenHidden)
      else
        Include(Node.Parent.States, vsAllChildrenHidden);
    end;

    InvalidateCache;
    if NeedUpdate and (FUpdateCount = 0) then
    begin
      ValidateCache;
      UpdateScrollBars(True);
      Invalidate;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetVisiblePath(Node: PVirtualNode; Value: Boolean);

// If Value is True then all parent nodes of Node are expanded.

begin
  Assert(Assigned(Node) and (Node <> FRoot), 'Invalid parameter.');

  if Value then
  begin
    repeat
      Node := Node.Parent;
      if Node = FRoot then
        Break;
      if not (vsExpanded in Node.States) then
        ToggleNode(Node);
    until False;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.StopTimer(ID: Integer);

begin
  if HandleAllocated then
    KillTimer(Handle, ID);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.TileBackground(Source: TBitmap; Target: TCanvas; Offset: TPoint; R: TRect);

// Draws the given source graphic so that it tiles into the given rectangle which is relative to the target bitmap.
// The graphic is aligned so that it always starts at the upper left corner of the target canvas.
// Offset gives the position of the target window in an possible superordinated surface.

var
  SourceX,
  SourceY,
  TargetX,

  DeltaY: Integer;
  
begin
  with Target do
  begin
    SourceY := (R.Top + Offset.Y + FBackgroundOffsetY) mod Source.Height;
    // Always wrap the source coordinates into positive range.
    if SourceY < 0 then
      SourceY := Source.Height + SourceY;

    // Tile image vertically until target rect is filled.
    while R.Top < R.Bottom do
    begin
      SourceX := (R.Left + Offset.X + FBackgroundOffsetX) mod Source.Width;
      // always wrap the source coordinates into positive range
      if SourceX < 0 then
        SourceX := Source.Width + SourceX;

      TargetX := R.Left;
      // height of strip to draw
      DeltaY := Min(R.Bottom - R.Top, Source.Height - SourceY);

      // tile the image horizontally
      while TargetX < R.Right do
      begin
        BitBlt(Handle, TargetX, R.Top, Min(R.Right - TargetX, Source.Width - SourceX), DeltaY,
          Source.Canvas.Handle, SourceX, SourceY, SRCCOPY);
        Inc(TargetX, Source.Width - SourceX);
        SourceX := 0;
      end;
      Inc(R.Top, Source.Height - SourceY);
      SourceY := 0;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.ToggleCallback(Step, StepSize: Integer; Data: Pointer): Boolean;

var
  ScrollRect: TRect;
  Column: Integer;
  Run: TRect;

  //--------------- local function --------------------------------------------

  procedure EraseLine;

  var
    LocalBrush: HBRUSH;

  begin
    with TToggleAnimationData(Data^), FHeader.FColumns do
    begin
      // Iterate through all columns and erase background in their local color.
      // LocalBrush is a brush in the color of the particular column.
      Column := ColumnFromPosition(Run.TopLeft);
      while (Column > InvalidColumn) and (Run.Left < ClientWidth) do
      begin
        GetColumnBounds(Column, Run.Left, Run.Right);
        if coParentColor in Items[Column].FOptions then
          FillRect(DC, Run, Brush)
        else
        begin
          LocalBrush := CreateSolidBrush(ColorToRGB(Items[Column].Color));
          FillRect(DC, Run, LocalBrush);
          DeleteObject(LocalBrush);
        end;
        Column := GetNextVisibleColumn(Column);
      end;
    end;
  end;

  //--------------- end local function ----------------------------------------

begin
  Result := True;
  if StepSize > 0 then
  begin
    with TToggleAnimationData(Data^) do
    begin
      ScrollRect := R;
      if Expand then
      begin
        ScrollDC(DC, 0, StepSize, ScrollRect, ScrollRect, 0, nil);

        // In the first step the background must be cleared (only a small stripe) to avoid artefacts.
        if Step = 0 then
          if not FHeader.UseColumns then
            FillRect(DC, Rect(R.Left, R.Top, R.Right, R.Top + StepSize + 1), Brush)
          else
          begin
            Run := Rect(R.Left, R.Top, R.Right, R.Top + StepSize + 1);
            EraseLine;
          end;
      end
      else
      begin
        // Collapse branch.
        ScrollDC(DC, 0, -StepSize, ScrollRect, ScrollRect, 0, nil);

        if Step = 0 then
          if not FHeader.UseColumns then
            FillRect(DC, Rect(R.Left, R.Bottom - StepSize - 1, R.Right, R.Bottom), Brush)
          else
          begin
            Run := Rect(R.Left, R.Bottom - StepSize - 1, R.Right, R.Bottom);
            EraseLine;
          end;
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.CMColorChange(var Message: TMessage);

begin
  if not (csLoading in ComponentState) then
  begin
    PrepareBitmaps(True, False);
    if HandleAllocated then
      Invalidate;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.CMCtl3DChanged(var Message: TMessage);

begin
  inherited;
  if FBorderStyle = bsSingle then
    RecreateWnd;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.CMEnabledChanged(var Message: TMessage);

begin
  inherited;

  // Need to invalidate the non-client area as well, since the header must be redrawn too.
  if csDesigning in ComponentState then
    RedrawWindow(Handle, nil, 0, RDW_FRAME or RDW_INVALIDATE or RDW_NOERASE or RDW_NOCHILDREN); 
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.CMDrag(var Message: TCMDrag);

var
  S: TObject;
  ShiftState: Integer;
  P: TPoint;
  DropEffect: Integer;
  Formats: TFormatArray;

begin
  with Message, DragRec^ do
  begin
    S := Source;
    Formats := nil;
    
    // let the ancestor handle dock operations
    if S is TDragDockObject then
      inherited
    else
    begin
      if S is TBaseDragControlObject then
        S := (S as TBaseDragControlObject).Control;
      case DragMessage of
        dmDragEnter, dmDragLeave, dmDragMove:
          begin
            if DragMessage = dmDragEnter then
              Include(FStates, tsVCLDragging);
            if DragMessage = dmDragLeave then
              Exclude(FStates, tsVCLDragging);
              
            if DragMessage = dmDragMove then
              with ScreenToClient(Pos) do
                DoAutoScroll(X, Y);
              
            ShiftState := 0;
            // Alt key will be queried by the KeysToShiftState function in DragOver.
            if GetKeyState(VK_SHIFT) < 0 then
              ShiftState := ShiftState or MK_SHIFT;
            if GetKeyState(VK_CONTROL) < 0 then
              ShiftState := ShiftState or MK_CONTROL;

            // Allowed drop effects are simulated for VCL dd.
            Result := DROPEFFECT_MOVE or DROPEFFECT_COPY;
            DragOver(S, ShiftState, TDragState(DragMessage), Pos, Result);
            FLastVCLDragTarget := FDropTargetNode;
            if (DragMessage = dmDragLeave) and Assigned(FDropTargetNode) then
            begin
              InvalidateNode(FDropTargetNode);
              FDropTargetNode := nil;
            end;
          end;
        dmDragDrop:
          begin
            ShiftState := 0;
            // Alt key will be queried by the KeysToShiftState function in DragOver
            if GetKeyState(VK_SHIFT) < 0 then
              ShiftState := ShiftState or MK_SHIFT;
            if GetKeyState(VK_CONTROL) < 0 then
              ShiftState := ShiftState or MK_CONTROL;

            // allowed drop effects are simulated for VCL dd,
            // replace target node with cached node from other VCL dd messages
            if Assigned(FDropTargetNode) then
              InvalidateNode(FDropTargetNode);
            FDropTargetNode := FLastVCLDragTarget;
            P := Point(Pos.X, Pos.Y);
            P := ScreenToClient(P);
            DropEffect := DROPEFFECT_MOVE or DROPEFFECT_COPY;
            DoDragDrop(S, nil, Formats, KeysToShiftState(ShiftState), P, DropEffect, FLastDropMode);
            if Assigned(FDropTargetNode) then
            begin
              InvalidateNode(FDropTargetNode);
              FDropTargetNode := nil;
            end;
          end;
        dmFindTarget:
          begin
            Result := Integer(ControlAtPos(ScreenToClient(Pos), False));
            if Result = 0 then
              Result := Integer(Self);

            // This is a reliable place to check whether VCL drag has
            // really begun.  
            if tsVCLDragPending in FStates then
              FStates := FStates - [tsVCLDragPending, tsEditPending, tsClearPending] + [tsVCLDragging];
          end;
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.CMFontChanged(var Message: TMessage);

begin
  inherited;

  if not (csLoading in ComponentState) then
  begin
    PrepareBitmaps(True, False);
    if HandleAllocated then
      Invalidate;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.CMHintShow(var Message: TCMHintShow);

// Determines hint message (tooltip) and out-of-hint rect.
// Note: A special handling is needed here because we cannot pass wide strings back to the caller.
//       I had to introduce the hint data record anyway so we can use this to pass the hint string.
//       We still need to set a dummy hint string in the message to make the VCL showing the hint window.

var
  NodeRect: TRect;
  SpanColumn,
  Dummy,
  ColLeft,
  ColRight: Integer;
  HitInfo: THitInfo;
  ShowOwnHint: Boolean;
  IsFocusedOrEditing: Boolean;
  ParentForm: TCustomForm;

begin
  with Message do
  begin
    Result := 1;
    // Make sure a hint is only shown if the tree or at least its parent form is active. Active editing is ok too.
    IsFocusedOrEditing := Focused;
    if not Focused then
    begin
      ParentForm := GetParentForm(Self);
      if Assigned(ParentForm) then
        IsFocusedOrEditing := ParentForm.Focused or (Screen.ActiveForm = ParentForm);
    end;
    if not IsFocusedOrEditing then
      IsFocusedOrEditing := IsEditing;

    if (GetCapture = 0) and ShowHint and not (Dragging or IsMouseSelecting) and ([tsScrolling] * FStates = []) and
      (FHeader.States = []) and IsFocusedOrEditing then
    begin
      Include(FStates, tsHintShown);
      with HintInfo^ do
      begin
        Result := 0;
        ShowOwnHint := False;
        // Assign a dummy string otherwise the VCL will not show the hint window.
        HintStr := 'x';
        HitInfo.HitNode := nil;
        
        // First check whether there is a header hint to show.
        if FHeader.UseColumns and (hoShowHint in FHeader.FOptions) and FHeader.InHeader(CursorPos) then
        begin                             
          CursorRect := FHeaderRect;
          // Convert the cursor rectangle into real client coordinates.
          OffsetRect(CursorRect, 0, -Integer(FHeader.FHeight));
          HitInfo.HitColumn := FHeader.FColumns.GetColumnAndBounds(CursorPos, CursorRect.Left, CursorRect.Right);
          // align the vertical hint position on the bottom bound of the header, but
          // avoid overlapping of mouse cursor and hint        
          HintPos.Y := Max(HintPos.Y, ClientToScreen(Point(0, CursorRect.Bottom)).Y);
          // Note: the test for the left mouse button in ControlState might cause problems whenever the VCL does not
          //       realize when the button is released. This, for instance, happens when doing OLE drag'n drop and
          //       cancel this with ESC.
          if (HitInfo.HitColumn > -1) and not (csLButtonDown in ControlState) then
          begin
            FHintData.DefaultHint := FHeader.FColumns[HitInfo.HitColumn].FHint;
            if FHintData.DefaultHint <> '' then
              ShowOwnHint := True
            else
              Result := 1;
          end
          else
            Result := 1;
        end
        else
        begin
          // Default mode is handled as would the tree be a usual VCL control (no own hint window necessary).
          if FHintMode = hmDefault then
            HintStr := GetShortHint(Hint)
          else
          begin
            // Determine node for which to show hint/tooltip.
            GetHitTestInfoAt(CursorPos.X, CursorPos.Y, True, HitInfo);

            if Assigned(HitInfo.HitNode) and (HitInfo.HitColumn > InvalidColumn) then
            begin
              // A draw tree should only display a hint when at least its OnGetHintSize
              // event handler is assigned.
              if Self is TCustomVirtualDrawTree then
              begin
                FHintData.HintRect := Rect(0, 0, 0, 0);
                with Self as TCustomVirtualDrawTree do
                  DoGetHintSize(HitInfo.HitNode, HitInfo.HitColumn, FHintData.HintRect);
                ShowOwnHint := not IsRectEmpty(FHintData.HintRect);
              end
              else
                // For string trees a decision about showing the hint or not is based
                // on the hint string (if it is empty then no hint is shown).
                ShowOwnHint := True;

              if ShowOwnHint then
              begin
                if HitInfo.HitColumn > NoColumn then
                begin
                  FHeader.FColumns.GetColumnBounds(HitInfo.HitColumn, ColLeft, ColRight);
                  // The right column border might be extended if column spanning is enabled.
                  if toAutoSpanColumns in FOptions.FAutoOptions then
                  begin
                    SpanColumn := HitInfo.HitColumn;
                    repeat
                      Dummy := FHeader.FColumns.GetNextVisibleColumn(SpanColumn);
                      if (Dummy = InvalidColumn) or not ColumnIsEmpty(HitInfo.HitNode, Dummy) then
                        Break;
                      SpanColumn := Dummy;
                    until False;
                    if SpanColumn <> HitInfo.HitColumn then
                      FHeader.FColumns.GetColumnBounds(SpanColumn, Dummy, ColRight);
                  end;
                end
                else
                begin
                  ColLeft := 0;
                  ColRight := ClientWidth;
                end;

                FHintData.DefaultHint :=  '';
                if FHintMode <> hmTooltip then
                begin
                  // Node specific hint text.
                  CursorRect := GetDisplayRect(HitInfo.HitNode, HitInfo.HitColumn, False);
                  // Align the vertical hint position on the bottom bound of the node, but
                  // avoid overlapping of mouse cursor and hint.
                  HintPos.Y := Max(HintPos.Y, ClientToScreen(CursorRect.BottomRight).Y) + 2;
                end
                else
                begin
                  // Tool tip to show. This means the caption of the node is to be shown (perhaps).
                  NodeRect := GetDisplayRect(HitInfo.HitNode, HitInfo.HitColumn, True, True);

                  if (HitInfo.HitColumn > InvalidColumn) and PtInRect(NodeRect, CursorPos) and
                    (CursorPos.X <= ColRight) and (CursorPos.X >= ColLeft) and
                    ((NodeRect.Right >= Min(ColRight, ClientWidth)) or (NodeRect.Left < Max(ColLeft, 0))) then
                  begin
                    // Node specific hint text given will be retrieved when needed.
                    FHintData.DefaultHint := '';
                    HintPos := ClientToScreen(Point(NodeRect.Left, NodeRect.Top));
                    CursorRect := NodeRect;
                  end
                  else
                    // nothing to show
                    Result := 1;
                end;
              end
              else
                Result := 1; // Avoid hint if this is a draw tree returning an empty hint rectangle.
            end
            else
            begin
              // No node so fall back to control's hint (if indicated) or show nothing.
              if FHintMode = hmHintAndDefault then
              begin
                FHintData.DefaultHint := GetShortHint(Hint);
                if Length(FHintData.DefaultHint) = 0 then
                  Result := 1
                else
                  ShowOwnHint := True;
              end
              else
                Result := 1;
            end;
          end;
        end;

        // Set our own hint window class and prepare structure to be passed to the hint window.
        if ShowOwnHint and (Result = 0) then
        begin
          HintWindowClass := TVirtualTreeHintWindow;

          FHintData.Tree := Self;
          FHintData.Column := HitInfo.HitColumn;
          FHintData.Node := HitInfo.HitNode;
          HintData := @FHintData;
        end
        else
          // Reset the internal flag to show that we need to immediately create our own hint window again
          // next time a CM_HINTSHOWPAUSE message is received.
          Exclude(FStates, tsHintShown);
      end;

      // Remind that a hint is about to show.
      if Result = 0 then
        Include(FStates, tsHint)
      else
        Exclude(FStates, tsHint);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.CMHintShowPause(var Message: TCMHintShowPause);

// Tells the application that the tree (and only the tree) does not want a delayed tool tip.
// Normal hints / header hints use the default delay (except the first time).

var
  P: TPoint;

begin
  // A little workaround is needed here to make the application class using the correct hint window class.
  // Once the application gets ShowHint set to true (which is the case when we want to show hints in the tree) then
  // an internal hint window will be created which is not our own class (because we don't set an application wide
  // hint window class but only one for the tree). Unfortunately, this default hint window class will prevent
  // hints for the non-client area to show up (e.g. for the header) by calling CancelHint whenever certain messages
  // arrive. By setting the hint show pause to 0 if this is the very first time that a hint is shown we make sure
  // that our own hint window class is used because the hint is immediately shown without using the hint timer (in Forms.pas).
  if tsHintShown in FStates then
  begin
    GetCursorPos(P);
    if not (FHeader.UseColumns and (hoShowHint in FHeader.FOptions) and
      FHeader.InHeader(ScreenToClient(P))) and (FHintMode = hmToolTip) then
      Message.Pause^ := 0
  end
  else
    Message.Pause^ := 0;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.CMMouseLeave(var Message: TMessage);

begin
  if [tsWheelPanning, tsWheelScrolling] * FStates = [] then
  begin
    StopTimer(ScrollTimer);
    FStates := FStates - [tsScrollPending, tsScrolling];
  end;
  if Assigned(FCurrentHotNode) then
  begin
    DoHotChange(FCurrentHotNode, nil);
    InvalidateNode(FCurrentHotNode);
    FCurrentHotNode := nil;
  end;
  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.CMMouseWheel(var Message: TCMMouseWheel);

var
  ScrollCount: Integer;
  P: TPoint;

begin
  StopWheelPanning;
  
  inherited;

  if Message.Result = 0  then
  begin
    with Message do
    begin
      Result := 1;
      if FRangeY > Cardinal(ClientHeight) then
      begin
        // scroll vertical if there's something to scroll...
        if ssCtrl in ShiftState then
          ScrollCount := WheelDelta div WHEEL_DELTA * (ClientHeight div Integer(FDefaultNodeHeight))
        else
          ScrollCount := WheelDelta div WHEEL_DELTA;
        SetOffsetY(FOffsetY + ScrollCount * Integer(FDefaultNodeHeight));
      end
      else
      begin
        // ...else scroll horizontally
        if ssCtrl in ShiftState then
          ScrollCount := WheelDelta div WHEEL_DELTA * ClientWidth
        else
          ScrollCount := WheelDelta div WHEEL_DELTA;
        SetOffsetX(FOffsetX + ScrollCount * Integer(FIndent));
      end;
    end;

    // finally update "hot" node if hot tracking is activated
    P := ScreenToClient(SmallPointToPoint(Message.Pos));
    if PtInRect(ClientRect, P) then
      HandleHotTrack(P.X, P.Y);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.CMSysColorChange(var Message: TMessage);

begin
  inherited;

  ConvertImageList(LightCheckImages, 'VT_CHECK_LIGHT');
  ConvertImageList(DarkCheckImages, 'VT_CHECK_DARK');
  ConvertImageList(LightTickImages, 'VT_TICK_LIGHT');
  ConvertImageList(DarkTickImages, 'VT_TICK_DARK');
  ConvertImageList(FlatImages, 'VT_FLAT');
  ConvertImageList(UtilityImages, 'VT_UTILITIES');
  // XP images do not need to be converted.
  Message.Msg := WM_SYSCOLORCHANGE;
  DefaultHandler(Message);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMChar(var Message: TWMChar);

begin
  if tsIncrementalSearchPending in FStates then
  begin
    HandleIncrementalSearch(Message.CharCode);
    Exclude(FStates, tsIncrementalSearchPending);
  end;

  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMContextMenu(var Message: TWMContextMenu);

// This method is called when a popup menu is about to be displayed.
// We have to cancel some pending states here to avoid interferences.

begin
  FStates := FStates - [tsClearPending, tsEditPending];

  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMCopy(var Message: TWMCopy);

begin
  CopyToClipboard;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMCut(var Message: TWMCut);

begin
  CutToClipboard;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMEnable(var Message: TWMEnable);

begin
  inherited;
  RedrawWindow(Handle, nil, 0, RDW_FRAME or RDW_INVALIDATE or RDW_NOERASE or RDW_NOCHILDREN);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMEraseBkgnd(var Message: TWMEraseBkgnd);

begin
  Message.Result := 1;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMGetDlgCode(var Message: TWMGetDlgCode);

begin
  Message.Result := DLGC_WANTCHARS or DLGC_WANTARROWS;
  if FWantTabs then
    Message.Result := Message.Result or DLGC_WANTTAB;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMHScroll(var Message: TWMVScroll);

  //--------------- local functions -------------------------------------------

  function GetRealScrollPosition: Integer;

  var
    SI: TScrollInfo;
    Code: Integer;

  begin
    SI.cbSize := SizeOf(TScrollInfo);
    SI.fMask := SIF_TRACKPOS;
    Code := SB_HORZ;
    {$ifdef UseFlatScrollbars}
      FlatSB_GetScrollInfo(Handle, Code, SI);
    {$else}
      GetScrollInfo(Handle, Code, SI);
    {$endif UseFlatScrollbars}
    Result := SI.nTrackPos;
  end;

  //--------------- end local functions ---------------------------------------

begin
  case Message.ScrollCode of
    SB_BOTTOM:
      SetOffsetX(-Integer(FRangeX));
    SB_ENDSCROLL:
      begin
        Exclude(FStates, tsThumbTracking);
        // avoiding to adjust the vertical scroll position while tracking makes it much smoother
        // but we need to adjust the final position here then
        UpdateHorizontalScrollBar(False);
      end;
    SB_LINELEFT:
      SetOffsetX(FOffsetX + FScrollBarOptions.FIncrementX);
    SB_LINERIGHT:
      SetOffsetX(FOffsetX - FScrollBarOptions.FIncrementX);
    SB_PAGELEFT:
      SetOffsetX(FOffsetX + ClientWidth);
    SB_PAGERIGHT:
      SetOffsetX(FOffsetX - ClientWidth);
    SB_THUMBPOSITION,
    SB_THUMBTRACK:
      begin
        Include(FStates, tsThumbTracking);
        SetOffsetX(-GetRealScrollPosition);
      end;
    SB_TOP:
      SetOffsetX(0);
  end;

  Message.Result := 0;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMKeyDown(var Message: TWMKeyDown);

// Keyboard event handling for node focus, selection, node specific popup menus and help invokation.
// For a detailed description of every action done here read the help.

var
  Shift: TShiftState;
  Node, Temp,
  LastFocused: PVirtualNode;
  Offset: Integer;
  ClearPending,
  NeedInvalidate,
  DoRangeSelect,
  HandleMultiSelect: Boolean;
  Context: Integer;
  ParentControl: TWinControl;
  R: TRect;
  NewCheckState: TCheckState;
  NewColumn: Integer;
  ActAsGrid: Boolean;

  // for tabulator handling
  GetStartColumn: function: TColumnIndex of object;
  GetNextColumn: function(Column: TColumnIndex): TColumnIndex of object;
  GetNextNode: TGetNextNodeProc;

begin
  // Make form key preview work and let application modify the key if it wants this.
  inherited;
  
  with Message do
  begin
    Shift := KeyDataToShiftState(KeyData);
    // Ask the application if the default key handling is desired.
    if DoKeyAction(CharCode, Shift) then
    begin         
      if CharCode in [VK_HOME, VK_END, VK_PRIOR, VK_NEXT, VK_UP, VK_DOWN, VK_LEFT, VK_RIGHT, VK_BACK, VK_TAB] then
      begin
        HandleMultiSelect := (ssShift in Shift) and (toMultiSelect in FOptions.FSelectionOptions) and not IsEditing;

        // Flag to avoid range selection in case of single node advance.
        DoRangeSelect := (CharCode in [VK_HOME, VK_END, VK_PRIOR, VK_NEXT]) and HandleMultiSelect and not IsEditing;
                  
        NeedInvalidate := DoRangeSelect or (FSelectionCount > 1);
        ActAsGrid := toGridExtensions in FOptions.FMiscOptions;
        ClearPending := (Shift = []) or (ActAsGrid and not (ssShift in Shift)) or
          not (toMultiSelect in FOptions.FSelectionOptions) or (CharCode in [VK_TAB, VK_BACK]);

        // Keep old focused node for range selection. Use a default node if none was focused until now.
        LastFocused := FFocusedNode;
        if (LastFocused = nil) and (Shift <> []) then
          LastFocused := GetFirstVisible;

        // Set an initial range anchor if there is not yet one.
        if FRangeAnchor = nil then
          FRangeAnchor := GetFirstSelected;

        // Determine new focused node.
        case CharCode of
          VK_HOME, VK_END:
            begin
              if CharCode = VK_END then
              begin
                GetStartColumn := FHeader.FColumns.GetLastVisibleColumn;
                GetNextColumn := FHeader.FColumns.GetPreviousVisibleColumn;
                GetNextNode := GetPreviousVisible;
                Node := GetLastVisible;
              end
              else
              begin
                GetStartColumn := FHeader.FColumns.GetFirstVisibleColumn;
                GetNextColumn := FHeader.FColumns.GetNextVisibleColumn;
                GetNextNode := GetNextVisible;
                Node := GetFirstVisible;
              end;

              // Advance to next/previous visible column.
              if FHeader.UseColumns then
                NewColumn := GetStartColumn
              else
                NewColumn := NoColumn;
              // Find a column for the new/current node which can be focused.
              while (NewColumn > NoColumn) and not DoFocusChanging(FFocusedNode, Node, FFocusedColumn, NewColumn) do
                NewColumn := GetNextColumn(NewColumn);
              if NewColumn > InvalidColumn then
              begin
                if (Shift = [ssCtrl]) and not ActAsGrid then
                begin
                  ScrollIntoView(Node, False);
                  if CharCode = VK_HOME then
                    SetOffsetX(0)
                  else
                    SetOffsetX(-MaxInt);
                end
                else
                begin
                  if not ActAsGrid or (ssCtrl in Shift) then
                    FocusedNode := Node;
                  if ActAsGrid and not (toFullRowSelect in FOptions.FSelectionOptions) then
                    FocusedColumn := NewColumn;
                end;
              end;
            end;
          VK_PRIOR:
            if ssCtrl in Shift then
              SetOffsetY(FOffsetY + ClientHeight)
            else
            begin
              Offset := 0;
              // If there's no focused node then just take the very first visible one.
              if FFocusedNode = nil then
                Node := GetFirstVisible
              else
              begin
                // Go up as many nodes as comprise together a size of ClientHeight.
                Node := FFocusedNode;
                while Offset < ClientHeight do
                begin
                  Temp := GetPreviousVisible(Node);
                  if Temp = nil then
                    Break;
                  Node := Temp;
                  Inc(Offset, Node.NodeHeight);
                end;
              end;
              FocusedNode := Node;
            end;
          VK_NEXT:
            if ssCtrl in Shift then
              SetOffsetY(FOffsetY - ClientHeight)
            else
            begin
              Offset := 0;
              // If there's no focused node then just take the very last one.
              if FFocusedNode = nil then
                Node := GetLastVisible
              else
              begin
                // Go up as many nodes as comprise together a size of ClientHeight.
                Node := FFocusedNode;
                while Offset < ClientHeight do
                begin
                  Temp := GetNextVisible(Node);
                  if Temp = nil then
                    Break;
                  Node := Temp;
                  Inc(Offset, Node.NodeHeight);
                end;
              end;
              FocusedNode := Node;
            end;
          VK_UP:
            begin
              // scrolling without selection change
              if ssCtrl in Shift then
                SetOffsetY(FOffsetY + Integer(FDefaultNodeHeight))
              else
              begin
                if FFocusedNode = nil then
                  Node := GetLastVisible
                else
                  Node := GetPreviousVisible(FFocusedNode);

                if Assigned(Node) then
                begin
                  EndEditNode;
                  if HandleMultiSelect and (CompareNodePositions(LastFocused, FRangeAnchor) > 0) and
                    Assigned(FFocusedNode) then
                    RemoveFromSelection(FFocusedNode);
                  if FFocusedColumn = NoColumn then
                    FFocusedColumn := FHeader.MainColumn;
                  FocusedNode := Node;
                end
                else
                  if Assigned(FFocusedNode) then
                    InvalidateNode(FFocusedNode);
              end;
            end;
          VK_DOWN:
            begin
              // scrolling without selection change
              if ssCtrl in Shift then
                SetOffsetY(FOffsetY - Integer(FDefaultNodeHeight))
              else
              begin
                if FFocusedNode = nil then
                  Node := GetFirstVisible
                else
                  Node := GetNextVisible(FFocusedNode);

                if Assigned(Node) then
                begin
                  EndEditNode;
                  if HandleMultiSelect and (CompareNodePositions(LastFocused, FRangeAnchor) < 0) and
                    Assigned(FFocusedNode) then
                    RemoveFromSelection(FFocusedNode);
                  if FFocusedColumn = NoColumn then
                    FFocusedColumn := FHeader.MainColumn;
                  FocusedNode := Node;
                end
                else
                  if Assigned(FFocusedNode) then
                    InvalidateNode(FFocusedNode);
              end;
            end;
          VK_LEFT:
            begin
              // special handling
              if ssCtrl in Shift then
                SetOffsetX(FOffsetX + Integer(FIndent))
              else
              begin
                // other special cases
                Context := NoColumn;
                if (toExtendedFocus in FOptions.FSelectionOptions) and (toGridExtensions in FOptions.FMiscOptions) then
                begin
                  Context := FHeader.Columns.GetPreviousVisibleColumn(FFocusedColumn);
                  if Context > -1 then
                    FocusedColumn := Context
                end
                else
                  if Assigned(FFocusedNode) and (vsExpanded in FFocusedNode.States) and
                     (Shift = []) and (vsHasChildren in FFocusedNode.States) then
                    ToggleNode(FFocusedNode)
                  else
                  begin
                    if FFocusedNode = nil then
                      FocusedNode := GetFirstVisible
                    else
                    begin
                      if FFocusedNode.Parent <> FRoot then
                        Node := FFocusedNode.Parent
                      else
                        Node := nil;
                      if Assigned(Node) then
                      begin
                        if HandleMultiSelect then
                        begin
                          // and a third special case
                          if FFocusedNode.Index > 0 then
                            DoRangeSelect := True
                          else
                           if CompareNodePositions(Node, FRangeAnchor) > 0 then
                             RemoveFromSelection(FFocusedNode);
                        end;
                        FocusedNode := Node;
                      end;
                    end;
                  end;
              end;
            end;
          VK_RIGHT:
            begin
              // special handling
              if ssCtrl in Shift then
                SetOffsetX(FOffsetX - Integer(FIndent))
              else
              begin
                // other special cases
                Context := NoColumn;
                if (toExtendedFocus in FOptions.FSelectionOptions) and (toGridExtensions in FOptions.FMiscOptions) then
                begin
                  Context := FHeader.Columns.GetNextVisibleColumn(FFocusedColumn);
                  if Context > -1 then
                    FocusedColumn := Context;
                end
                else
                  if Assigned(FFocusedNode) and not (vsExpanded in FFocusedNode.States) and
                     (Shift = []) and (vsHasChildren in FFocusedNode.States) then
                    ToggleNode(FFocusedNode)
                  else
                  begin
                    if FFocusedNode = nil then
                      FocusedNode := GetFirstVisible
                    else
                    begin
                      Node := GetFirstVisibleChild(FFocusedNode);
                      if Assigned(Node) then
                      begin
                        if HandleMultiSelect and (CompareNodePositions(Node, FRangeAnchor) < 0) then
                          RemoveFromSelection(FFocusedNode);
                        FocusedNode := Node;
                      end;
                    end;
                  end;
              end;
            end;
          VK_BACK:
            if Assigned(FFocusedNode) and (FFocusedNode.Parent <> FRoot) then
              FocusedNode := FocusedNode.Parent;
          VK_TAB:
            if (toExtendedFocus in FOptions.FSelectionOptions) and FHeader.UseColumns then
            begin
              // In order to avoid duplicating source code just to change the direction
              // we use function variables.
              if ssShift in Shift then
              begin
                GetStartColumn := FHeader.FColumns.GetLastVisibleColumn;
                GetNextColumn := FHeader.FColumns.GetPreviousVisibleColumn;
                GetNextNode := GetPreviousVisible;
              end
              else
              begin
                GetStartColumn := FHeader.FColumns.GetFirstVisibleColumn;
                GetNextColumn := FHeader.FColumns.GetNextVisibleColumn;
                GetNextNode := GetNextVisible;
              end;

              // Advance to next/previous visible column/node.
              Node := FFocusedNode;
              NewColumn := GetNextColumn(FFocusedColumn);
              repeat
                // Find a column for the current node which can be focused.
                while (NewColumn > NoColumn) and not DoFocusChanging(FFocusedNode, Node, FFocusedColumn, NewColumn) do
                  NewColumn := GetNextColumn(NewColumn);

                if NewColumn > NoColumn then
                begin
                  FocusedNode := Node;
                  FocusedColumn := NewColumn;
                  Break;
                end;

                // No next column was accepted for the current node. So advance to next node and try again.
                Node := GetNextNode(Node);
                NewColumn := GetStartColumn;
              until Node = nil;
            end;
        end;
         
        // Clear old selection if required but take care about change events.
        if ClearPending then
          if (LastFocused = FFocusedNode) and (FSelectionCount <= 1) then
            InternalClearSelection
          else
            ClearSelection;

        // Determine new selection anchor.
        if Shift = [] then
        begin
          FRangeAnchor := FFocusedNode;
          FLastSelectionLevel := GetNodeLevel(FFocusedNode);
        end;
        // Finally change the selection for a specific range of nodes.
        if DoRangeSelect then
          ToggleSelection(LastFocused, FFocusedNode);

        // Make sure the new focused node is also selected.
        // Avoid change event if this node was already the only selected node.
        if Assigned(FFocusedNode) then
          if LastFocused = FFocusedNode then
            InternalAddToSelection(FFocusedNode, False)
          else
            AddToSelection(FFocusedNode);
            
        // If a repaint is needed then paint the entire tree because of the ClearSelection call,
        if NeedInvalidate then
          Invalidate;
      end
      else 
        // Second chance for keys not directly concerned with selection changes.
        case CharCode of
          VK_F2:
            if (Shift = []) and Assigned(FFocusedNode) and CanEdit(FFocusedNode, FFocusedColumn) then
            begin
              FEditColumn := FFocusedColumn;
              DoEdit;
            end;
          187,
          VK_ADD:
            begin
              if ssCtrl in Shift then
                if {$ifdef ReverseFullExpandHotKey} not {$endif ReverseFullExpandHotKey} (ssShift in Shift) then
                  FullExpand
                else
                  FHeader.AutoFitColumns
              else
                if Assigned(FFocusedNode) and not (vsExpanded in FFocusedNode.States) then
                  ToggleNode(FFocusedNode);
            end;
          189,
          VK_SUBTRACT:
            if ssCtrl in Shift then
              if {$ifdef ReverseFullExpandHotKey} not {$endif ReverseFullExpandHotKey} (ssShift in Shift) then
                FullCollapse
              else
                FHeader.RestoreColumns
            else
              if Assigned(FFocusedNode) and (vsExpanded in FFocusedNode.States) then
                ToggleNode(FFocusedNode);
          VK_MULTIPLY:
            if Assigned(FFocusedNode) then
              FullExpand(FFocusedNode);
          VK_DIVIDE:
            if Assigned(FFocusedNode) then
              FullCollapse(FFocusedNode);
          VK_ESCAPE: // cancel actions currently in progress
            begin
              if IsMouseSelecting then
              begin
                FStates := FStates - [tsDrawSelecting, tsDrawSelPending];
                Invalidate;
              end
              else
                if IsEditing then
                  CancelEditNode;
            end;
          VK_SPACE:
            if (toCheckSupport in FOptions.MiscOptions) and (FFocusedNode.CheckType <> ctNone) then
            begin
              if (FCheckNode = nil) and Assigned(FFocusedNode) and not (vsDisabled in FFocusedNode.States) then
              begin
                with FFocusedNode^ do
                  NewCheckState := DetermineNextCheckState(CheckType, CheckState);
                if DoChecking(FFocusedNode, NewCheckState) then
                begin
                  FCheckNode := FFocusedNode;
                  FPendingCheckState := NewCheckState;
                  FCheckNode.CheckState := PressedState[FCheckNode.CheckState];
                  RepaintNode(FCheckNode);
                end;
              end;
            end
            else
              Include(FStates, tsIncrementalSearchPending);
          VK_F1:
            if Assigned(FOnGetHelpContext) then
            begin
              Context := 0;
              if Assigned(FFocusedNode) then
              begin
                Node := FFocusedNode;
                // Traverse the tree structure up to the root.
                repeat
                  FOnGetHelpContext(Self, Node, 0, Context);
                  Node := Node.Parent;
                until (Node = FRoot) or (Context <> 0);
              end;

              // If no help context could be found try the tree's one or its parent's contexts.
              ParentControl := Self;
              while Assigned(ParentControl) and (Context = 0) do
              begin
                Context := ParentControl.HelpContext;
                ParentControl := ParentControl.Parent;
              end;
              if Context <> 0 then
                Application.HelpContext(Context);
            end;
          VK_APPS:
            if Assigned(FFocusedNode) then
            begin
              R := GetDisplayRect(FFocusedNode, FFocusedColumn, True);
              Offset := DoGetNodeWidth(FFocusedNode, FFocusedColumn);
              if FFocusedColumn >= 0 then
              begin
                if Offset > FHeader.Columns[FFocusedColumn].Width then
                  Offset := FHeader.Columns[FFocusedColumn].Width;
              end
              else
              begin
                if Offset > ClientWidth then
                  Offset := ClientWidth;
              end;
              DoPopupMenu(FFocusedNode, FFocusedColumn,
                Point(R.Left + Offset div 2, (R.Top + R.Bottom) div 2));
            end;
          Ord('a'), Ord('A'):
            if ssCtrl in Shift then
              SelectAll(True)
            else
              Include(FStates, tsIncrementalSearchPending);
        else
        begin
          // Use the key for incremental search.
          // Since we are dealing with Unicode all the time there should be a more sophisticated way
          // of checking for valid characters for incremental search.
          // This is available but would require to include a significant amount of Unicode character
          // properties, so we stick with the simple space check.
          if (Shift = []) and (CharCode >= 32) then
            Include(FStates, tsIncrementalSearchPending);
          end;
        end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMKeyUp(var Message: TWMKeyUp);

begin
  inherited;

  case Message.CharCode of
    VK_SPACE:
      begin
        // An assigned check node shows a pending check event.
        if Assigned(FCheckNode) then
        begin
          if FCheckNode = FFocusedNode then
            DoCheckClick(FCheckNode, FPendingCheckState);
          InvalidateNode(FCheckNode);
          FCheckNode := nil;
        end;
      end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMKillFocus(var Msg: TWMKillFocus);

var
  Form: TCustomForm;
  
begin
  inherited;

  // Stop wheel panning if active.
  StopWheelPanning;
  
  // Don't let any timer continue if the tree is no longer the active control (except change timers).
  StopTimer(ExpandTimer);
  StopTimer(EditTimer);
  Exclude(FStates, tsEditPending);
  StopTimer(HeaderTimer);
  StopTimer(ScrollTimer);
  StopTimer(SearchTimer);
  FStates := FStates - [tsScrollPending, tsScrolling];

  if FSelectionCount > 0 then
    Invalidate
  else
    if Assigned(FFocusedNode) then
      InvalidateNode(FFocusedNode);

  // Work around for MDI child parent form problem. If the tree lost the focus
  // because another form is activated then it does not get the focus back even
  // if set in code.
  Form := GetParentForm(Self);
  if Form is TForm then // returns also False if Form is nil
    with Form as TForm do
      if (FormStyle = fsMDIChild) and not Active then
        ActiveControl := nil;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMLButtonDblClk(var Message: TWMLButtonDblClk);

var
  HitInfo: THitInfo;

begin
  inherited;

  // get information about the hit
  GetHitTestInfoAt(Message.XPos, Message.YPos, True, HitInfo);
  HandleMouseDblClick(Message, HitInfo);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMLButtonDown(var Message: TWMLButtonDown);

var
  HitInfo: THitInfo;
  
begin
  Include(FStates, tsLeftButtonDown);
  inherited;

  // get information about the hit
  GetHitTestInfoAt(Message.XPos, Message.YPos, True, HitInfo);
  HandleMouseDown(Message, HitInfo);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMLButtonUp(var Message: TWMLButtonUp);

var
  HitInfo: THitInfo;
  
begin
  Exclude(FStates, tsLeftButtonDown);

  // get information about the hit
  GetHitTestInfoAt(Message.XPos, Message.YPos, True, HitInfo);
  HandleMouseUp(Message, HitInfo);

  inherited;

end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMMButtonDblClk(var Message: TWMMButtonDblClk);

var
  HitInfo: THitInfo;

begin
  inherited;

  // get information about the hit
  if toMiddleClickSelect in FOptions.FSelectionOptions then
  begin
    GetHitTestInfoAt(Message.XPos, Message.YPos, True, HitInfo);
    HandleMouseDblClick(Message, HitInfo);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMMButtonDown(var Message: TWMMButtonDown);

var
  HitInfo: THitInfo;

begin
  Include(FStates, tsMiddleButtonDown);
  
  if FHeader.FStates = [] then
  begin
    inherited;

    // Start whell panning or scrolling if not already active, allowed and scrolling is useful at all.
    if (toWheelPanning in FOptions.FMiscOptions) and ([tsWheelScrolling, tsWheelPanning] * FStates = []) and
      ((Integer(FRangeX) > ClientWidth) or (Integer(FRangeY) > ClientHeight)) then
    begin
      FLastClickPos := SmallPointToPoint(Message.Pos);
      StartWheelPanning(FLastClickPos);
    end
    else
    begin
      StopWheelPanning;

      // Get information about the hit.
      if toMiddleClickSelect in FOptions.FSelectionOptions then
      begin
        GetHitTestInfoAt(Message.XPos, Message.YPos, True, HitInfo);
        HandleMouseDown(Message, HitInfo);
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMMButtonUp(var Message: TWMMButtonUp);

var
  HitInfo: THitInfo;

begin
  Exclude(FStates, tsMiddleButtonDown);

  // If wheel panning/scrolling is active and the mouse has not yet been moved then the user starts wheel auto scrolling.
  // Indicate this by removing the panning flag. Otherwise (the mouse has moved meanwhile) stop panning.
  if [tsWheelPanning, tsWheelScrolling] * FStates <> [] then
  begin
    if tsWheelScrolling in FStates then
      Exclude(FStates, tsWheelPanning)
    else
      StopWheelPanning;
  end
  else
    if FHeader.FStates = [] then
    begin
      inherited;

      // get information about the hit
      if toMiddleClickSelect in FOptions.FSelectionOptions then
      begin
        GetHitTestInfoAt(Message.XPos, Message.YPos, True, HitInfo);
        HandleMouseUp(Message, HitInfo);
      end;
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMNCCalcSize(var Message: TWMNCCalcSize);

begin
  inherited;

  with FHeader do
    if hoVisible in FHeader.FOptions then
      with Message.CalcSize_Params^ do
        Inc(rgrc[0].Top, FHeight);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMNCDestroy(var Message: TWMNCDestroy);

// Used to release a reference of the drag manager. This is the only reliable way we get notified about
// window destruction, because of the automatic release of a window if its parent window is freed.

begin 
  StopTimer(ChangeTimer);
  StopTimer(StructureChangeTimer);

  if not (csDesigning in ComponentState) and (toAcceptOLEDrop in FOptions.FMiscOptions) then
    RevokeDragDrop(Handle);
    
  // Clean up other stuff which will be created when the window is created.
  DeleteObject(FDottedBrush);
  FDottedBrush := 0;

  if FTreeTheme <> 0 then
    CloseThemeData(FTreeTheme);
  if FButtonTheme <> 0 then
    CloseThemeData(FButtonTheme);
  FHeader.Columns.FreeTheme;

  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMNCHitTest(var Message: TWMNCHitTest);

begin
  inherited;
  if not (csDesigning in ComponentState) and (hoVisible in FHeader.FOptions) and
    FHeader.InHeader(ScreenToClient(SmallPointToPoint(Message.Pos))) then
    Message.Result := HTBORDER;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMNCPaint(var Message: TRealWMNCPaint);

var
  DC: HDC;
  R: TRect;
  Flags: DWORD;

begin
  // Don't use the inherited NC paint handler as it doesn't consider the current clipping region
  // leading so to annoying flicker.
  // If the tree is themed then the border which is drawn by the inherited handler will be overpainted.
  // This will, at time, cause a bit flicker, but since I found nowhwere documentation about how to do it right
  // I have to live with that for the time being.
  DefaultHandler(Message);

  Flags := DCX_CACHE or DCX_CLIPSIBLINGS or DCX_CLIPCHILDREN or DCX_WINDOW or DCX_VALIDATE;

  if (Message.Rgn = 1) or not IsWinNT then
    DC := GetDCEx(Handle, 0, Flags)
  else
    DC := GetDCEx(Handle, Message.Rgn, Flags or DCX_INTERSECTRGN);

  if DC <> 0 then
  begin
    if hoVisible in FHeader.FOptions then
    begin
      R := FHeaderRect;
      FHeader.FColumns.PaintHeader(DC, R, FOffsetX);
    end;
    OriginalWMNCPaint(DC);
    ReleaseDC(Handle, DC);
  end;

  Message.Result := 0;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMPaint(var Message: TWMPaint);

begin
  ControlState := ControlState + [csCustomPaint];
  if tsVCLDragging in FStates then
    ImageList_DragShowNolock(False);
  inherited;
  if tsVCLDragging in FStates then
    ImageList_DragShowNolock(True);
  ControlState := ControlState - [csCustomPaint];
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMPaste(var Message: TWMPaste);

begin
  PasteFromClipboard;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMPrint(var Message: TWMPrint);

// This message is sent to request that the tree draws itself to a given device context. This includes not only
// the client area but also the non-client area (header!).

begin
  // Draw only if the window is visible or visibility is not required.
  if ((Message.Flags and PRF_CHECKVISIBLE) = 0) or IsWindowVisible(Handle) then
    Header.Columns.PaintHeader(Message.DC, FHeaderRect, FOffsetX);

  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMPrintClient(var Message: TWMPrintClient);

var
  Window: TRect;
  Target: TPoint;
  Canvas: TCanvas;

begin  
  // Draw only if the window is visible or visibility is not required.
  if ((Message.Flags and PRF_CHECKVISIBLE) = 0) or IsWindowVisible(Handle) then
  begin
    // Determine area of the entire tree to be displayed in the control.
    Window := ClientRect;
    Target := Window.TopLeft;

    // The Window rectangle is given in client coordinates. We have to convert it into
    // a sliding window of the tree image.
    OffsetRect(Window, -FOffsetX, -FOffsetY);

    Canvas := TCanvas.Create;
    try
      Canvas.Handle := Message.DC;
      PaintTree(Canvas, Window, Target, [poBackground, poDrawFocusRect, poDrawDropMark, poDrawSelection, poGridLines]);
    finally
      Canvas.Handle := 0;
      Canvas.Free;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMRButtonDblClk(var Message: TWMRButtonDblClk);

var
  HitInfo: THitInfo;

begin
  inherited;

  // get information about the hit
  if toMiddleClickSelect in FOptions.FSelectionOptions then
  begin
    GetHitTestInfoAt(Message.XPos, Message.YPos, True, HitInfo);
    HandleMouseDblClick(Message, HitInfo);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMRButtonDown(var Message: TWMRButtonDown);

var
  HitInfo: THitInfo;

begin
  Include(FStates, tsRightButtonDown);

  if FHeader.FStates = [] then
  begin
    inherited;

    // get information about the hit
    if toRightClickSelect in FOptions.FSelectionOptions then
    begin
      GetHitTestInfoAt(Message.XPos, Message.YPos, True, HitInfo);
      HandleMouseDown(Message, HitInfo);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMRButtonUp(var Message: TWMRButtonUp);

// handle right click selection and node specific popup menu

var
  HitInfo: THitInfo;

begin
  Exclude(FStates, tsRightButtonDown);

  if FHeader.FStates = [] then
  begin
    Application.CancelHint;

    if IsMouseSelecting and Assigned(PopupMenu) then
    begin
      // Reset selection state already here, before the inherited handler opens the default menu.
      FStates := FStates - [tsDrawSelecting, tsDrawSelPending];
      Invalidate;
    end;

    inherited;

    // get information about the hit
    GetHitTestInfoAt(Message.XPos, Message.YPos, True, HitInfo);

    if toRightClickSelect in FOptions.FSelectionOptions then
      HandleMouseUp(Message, HitInfo);

    if not Assigned(PopupMenu) then
      DoPopupMenu(HitInfo.HitNode, HitInfo.HitColumn, Point(Message.XPos, Message.YPos));
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMReleaseEditLink(var Message: TMessage);

begin
  // Finally free edit link memory after editing has been finished.
  if not IsEditing then
    FEditLink := nil;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMSetCursor(var Message: TWMSetCursor);

// Sets the hot node mouse cursor for the tree. Cursor changes for the header are handled in Header.HandleMessage.

var
  NewCursor: TCursor;

begin
  with Message do
  begin
    if (CursorWnd = Handle) and not (csDesigning in ComponentState) then
    begin
      if [tsWheelPanning, tsWheelScrolling] * FStates <> [] then
      begin
        beep;
      end
      else
        if not FHeader.HandleMessage(TMessage(Message)) then
        begin
          // Apply own cursors only if there is no global cursor set.
          if Screen.Cursor = crDefault then
          begin
            if (toHotTrack in FOptions.PaintOptions) and Assigned(FCurrentHotNode) then
              NewCursor := FHotCursor
            else
              NewCursor := Cursor;

            DoGetCursor(NewCursor);
            Windows.SetCursor(Screen.Cursors[NewCursor]);
            Message.Result := 1;
          end
          else
            inherited;
        end;
    end
    else
      inherited;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMSetFocus(var Msg: TWMSetFocus);

begin
  inherited;
  if FSelectionCount > 0 then
    Invalidate
  else
    if Assigned(FFocusedNode) then
      InvalidateNode(FFocusedNode);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMSize(var Message: TWMSize);

begin
  inherited;

  // Need to update scroll bars here. This will cause a recursion because of the change of the client area
  // when changing a scrollbar. Usually this is no problem since with the second level recursion no change of the
  // window size happens (the same values for the scrollbars are set, which shouldn't cause a window size change).
  // Appearently, this applies not to all systems, however?.
  if HandleAllocated and ([tsSizing, tsWindowCreating] * FStates = []) and (ClientHeight > 0) then
  try
    Include(FStates, tsSizing);
    // This call will invalidate the entire non-client area which needs recalculation on resize.
    FHeader.RecalculateHeader;
    UpdateScrollBars(True);

    if (tsEditing in FStates) and not FHeader.UseColumns then
      UpdateEditBounds;
  finally
    Exclude(FStates, tsSizing);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMThemeChanged(var Message: TMessage);

// The user has changed the current theme or its enabled state.

begin
  if FTreeTheme <> 0 then
  begin
    CloseThemeData(FTreeTheme);
    FTreeTheme := 0;
  end;
  if FButtonTheme <> 0 then
  begin
    CloseThemeData(FButtonTheme);
    FButtonTheme := 0;
  end;

  if UseThemes and (toThemeAware in TreeOptions.PaintOptions) then
    Include(FStates, tsUseThemes)
  else
    Exclude(FStates, tsUseThemes);

  if tsUseThemes in FStates then
  begin
    FTreeTheme := OpenThemeData(Handle, 'treeview');
    FButtonTheme := OpenThemeData(Handle, 'button');
    FHeader.Columns.UpdateTheme(Handle);
  end;

  PrepareBitmaps(True, False);

  RedrawWindow(Handle, nil, 0, RDW_FRAME or RDW_INVALIDATE or RDW_NOERASE or RDW_NOCHILDREN);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMTimer(var Message: TWMTimer);

// centralized timer handling happens here

begin
  with Message do
  begin
    case TimerID of
      ExpandTimer:
        DoDragExpand;
      EditTimer:
        DoEdit;
      ScrollTimer:
        begin
          if tsScrollPending in FStates then
          begin  
            Application.CancelHint;
            // Scroll delay has elapsed, set to normal scroll interval now.
            SetTimer(Handle, ScrollTimer, FAutoScrollInterval, nil);
            FStates := FStates - [tsScrollPending] + [tsScrolling];
          end;
          DoTimerScroll;
        end;
      ChangeTimer:
        DoChange(FLastChangedNode);
      StructureChangeTimer:
        DoStructureChange(FLastStructureChangeNode, FLastStructureChangeReason);
      SearchTimer:
        begin
          // When this event triggers then the user did not pressed any key for the specified timeout period.
          // Hence incremental searching is stopped.
          Exclude(FStates, tsIncrementalSearching);
          StopTimer(SearchTimer);
          FSearchBuffer := '';
          FLastSearchNode := nil; 
        end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WMVScroll(var Message: TWMVScroll);

  //--------------- local functions -------------------------------------------

  function GetRealScrollPosition: Integer;

  var
    SI: TScrollInfo;
    Code: Integer;

  begin
    SI.cbSize := SizeOf(TScrollInfo);
    SI.fMask := SIF_TRACKPOS;
    Code := SB_VERT;
    {$ifdef UseFlatScrollbars}
      FlatSB_GetScrollInfo(Handle, Code, SI);
    {$else}
      GetScrollInfo(Handle, Code, SI);
    {$endif UseFlatScrollbars}
    Result := SI.nTrackPos;
  end;

  //--------------- end local functions ---------------------------------------

begin
  case Message.ScrollCode of
    SB_BOTTOM:
      SetOffsetY(-Integer(FRoot.TotalHeight));
    SB_ENDSCROLL:
      begin
        Exclude(FStates, tsThumbTracking);
        // Avoiding to adjust the horizontal scroll position while tracking makes scrolling much smoother
        // but we need to adjust the final position here then.
        UpdateScrollBars(True);
        // Really weird invalidation needed here (and I do it only because it happens so rarely), because
        // when showing the horizontal scrollbar while scrolling down using the down arrow button,
        // the button will be repainted on mouse up (on the wrong place in the far right lower corner)...
        RedrawWindow(Handle, nil, 0, RDW_FRAME or RDW_INVALIDATE or RDW_NOERASE or RDW_NOCHILDREN);
      end;
    SB_LINEUP:
      SetOffsetY(FOffsetY + FScrollBarOptions.FIncrementY);
    SB_LINEDOWN:
      SetOffsetY(FOffsetY - FScrollBarOptions.FIncrementY);
    SB_PAGEUP:
      SetOffsetY(FOffsetY + ClientHeight);
    SB_PAGEDOWN:
      SetOffsetY(FOffsetY - ClientHeight);

    SB_THUMBPOSITION,
    SB_THUMBTRACK:
      begin
        Include(FStates, tsThumbTracking);
        SetOffsetY(-GetRealScrollPosition);
      end;
    SB_TOP:
      SetOffsetY(0);
  end;
  Message.Result := 0;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.AddToSelection(Node: PVirtualNode);

var
  Changed: Boolean;

begin
  Assert(Assigned(Node), 'Node must not be nil!');
  FSingletonNodeArray[0] := Node;
  Changed := InternalAddToSelection(FSingletonNodeArray, 1, False);
  if Changed then
    Change(Node);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.AddToSelection(const NewItems: TNodeArray; NewLength: Integer; ForceInsert: Boolean = False);

// Adds the given items all at once into the current selection array. NewLength is the amount of
// nodes to add (necessary to allow NewItems to be larger than the actual used entries).
// ForceInsert is True if nodes must be inserted without consideration of level select constraint or
// already set selected flags (e.g. when loading from stream).
// Note: In the case ForceInsert is True the caller is responsible for making sure the new nodes aren't already in the
//       selection array! 

var
  Changed: Boolean;

begin
  Changed := InternalAddToSelection(NewItems, NewLength, ForceInsert);
  if Changed then
  begin
    if NewLength = 1 then
      Change(NewItems[0])
    else
      Change(nil);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.AdjustPaintCellRect(var PaintInfo: TVTPaintInfo; var NextNonEmpty: TColumnIndex);

// Used in descentants to modify the clip rectangle of the current column while painting a certain node.

begin
  // Since cells are always drawn from left to right the next column index is independent of the
  // bidi mode, but not the column borders which might change depending on the cell's content. 
  NextNonEmpty := FHeader.FColumns.GetNextVisibleColumn(PaintInfo.Column);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.AdjustPanningCursor(X, Y: Integer);

// Triggered by a mouse move when wheel panning/scrolling is active.
// Loads the proper cursor which indicates into which direction scrolling is done.

var
  Name: string;
  NewCursor: HCURSOR;
  ScrollHorizontal,
  ScrollVertical: Boolean;

begin
  ScrollHorizontal := Integer(FRangeX) > ClientWidth;
  ScrollVertical := Integer(FRangeY) > ClientHeight;

  if (Abs(X - FLastClickPos.X) < 8) and (Abs(Y - FLastClickPos.Y) < 8) then
  begin
    // Mouse is in the neutral zone.
    if ScrollHorizontal then
    begin
      if ScrollVertical then
        Name := 'VT_MOVEALL'
      else
        Name := 'VT_MOVEEW'
    end
    else
      Name := 'VT_MOVENS';
  end
  else
  begin
    // One of 8 directions applies: north, north-east, east, south-east, south, south-west, west and north-west.
    // Check also if scrolling in the particular direction is posible.
    if ScrollVertical and ScrollHorizontal then
    begin
      // All directions allowed.
      if X - FlastClickPos.X < -8 then
      begin
        // Left hand side.
        if Y - FLastClickPos.Y < -8 then
          Name := 'VT_MOVENW'
        else
          if Y - FLastClickPos.Y > 8 then
            Name := 'VT_MOVESW'
          else
            Name := 'VT_MOVEW';
      end
      else
        if X - FLastClickPos.X > 8 then
        begin
          // Right hand side.
          if Y - FLastClickPos.Y < -8 then
            Name := 'VT_MOVENE'
          else
            if Y - FLastClickPos.Y > 8 then
              Name := 'VT_MOVESE'
            else
              Name := 'VT_MOVEE';
        end
        else
        begin
          // Up or down.
          if Y < FLastClickPos.Y then
            Name := 'VT_MOVEN'
          else
            Name := 'VT_MOVES';
        end;
    end
    else
      if ScrollHorizontal then
      begin
        // Only horizontal movement allowed.
        if X < FlastClickPos.X then
          Name := 'VT_MOVEW'
        else
          Name := 'VT_MOVEE';
      end
      else
      begin
        // Only vertical movement allowed.
        if Y < FlastClickPos.Y then
          Name := 'VT_MOVEN'
        else
          Name := 'VT_MOVES';
      end;
  end;

  // Now load the cursor and apply it.
  NewCursor := LoadCursor(HInstance, PChar(Name));
  if FPanningCursor <> NewCursor then
  begin
    DeleteObject(FPanningCursor);
    FPanningCursor := NewCursor;
    Windows.SetCursor(FPanningCursor);
  end
  else
    DeleteObject(NewCursor);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.AdviseChangeEvent(StructureChange: Boolean; Node: PVirtualNode; Reason: TChangeReason);

// Used to register a delayed change event. If StructureChange is False then we have a selection change event (without
// a specific reason) otherwise it is a structure change.

begin
  if StructureChange then
  begin
    if tsStructureChangePending in FStates then
      StopTimer(StructureChangeTimer)
    else
      Include(FStates, tsStructureChangePending);

    FLastStructureChangeNode := Node;
    if FLastStructureChangeReason = crIgnore then
      FLastStructureChangeReason := Reason
    else
      if Reason <> crIgnore then
        FLastStructureChangeReason := crAccumulated;
  end
  else
  begin
    if tsChangePending in FStates then
      StopTimer(ChangeTimer)
    else
      Include(FStates, tsChangePending);

    FLastChangedNode := Node;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.AllocateInternalDataArea(Size: Cardinal): Cardinal;

// Simple registration method to be called by each descentant to claim their internal data area.
// Result is the offset from the begin of the node to the internal data area of the calling tree class.

begin
  Assert((FRoot = nil) or (FRoot.ChildCount = 0), 'Internal data allocation must be done before any node is created.');

  Result := TreeNodeSize + FTotalInternalDataSize;
  Inc(FTotalInternalDataSize, (Size + 3) and not 3);
  InitRootNode(Result);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.Animate(Steps, Duration: Integer; Callback: TVTAnimationCallback; Data: Pointer);

// This method does the calculation part of an animation as used for node toggling and hint animations.
// Steps is the maximum amount of animation steps to do and Duration determines the milliseconds the animation
// has to run. Callback is a task specific method which is called in the loop for every step and Data is simply
// something to pass on to the callback.
// The callback is called with the current step, the current step size and the Data parameter. Since the step amount
// as well as the step size are possibly adjusted during the animation, it is impossible to determine if the current
// step is the last step, even if the original step amount is known. To solve this problem the callback will be
// called after the loop has finished with a step size of 0 indicating so to execute any post processing.

var
  StepSize,
  RemainingTime,
  RemainingSteps,
  NextTimeStep,
  CurrentStep,
  StartTime,
  CurrentTime: Integer;

begin
  if not (tsInAnimation in FStates) and (Duration > 0) then
  begin
    Include(FStates, tsInAnimation);
    try
      RemainingTime := Duration;
      RemainingSteps := Steps;

      // Determine the initial step size which is either 1 if the needed steps are less than the number of
      // steps possible given by the duration or > 1 otherwise.
      StepSize := Round(Max(1, RemainingSteps / Duration));
      RemainingSteps := RemainingSteps div StepSize;   
      CurrentStep := 0;

      while (RemainingSteps > 0) and (RemainingTime > 0) and not Application.Terminated do
      begin
        StartTime := timeGetTime;
        NextTimeStep := StartTime + RemainingTime div RemainingSteps;
        if not Callback(CurrentStep, StepSize, Data) then
          Break;

        // Keep duration for this step for rest calculation.
        CurrentTime := timeGetTime;
        // Wait until the calculated time has been reached.
        while CurrentTime < NextTimeStep do
          CurrentTime := timeGetTime;

        // Subtract the time this step really needed.
        Dec(RemainingTime, CurrentTime - StartTime);
        Dec(RemainingSteps);
        // If the remaining time per step is less than one time step then we have to decrease the
        // step count and increase the step size.
        if (RemainingSteps > 0) and ((RemainingTime div RemainingSteps) < 1) then
        begin
          repeat
            Inc(StepSize);
            RemainingSteps := RemainingTime div StepSize;
          until (RemainingSteps <= 0) or ((RemainingTime div RemainingSteps) >= 1);
        end;
        CurrentStep := Steps - RemainingSteps;
      end;

      if not Application.Terminated then
        Callback(0, 0, Data);
    finally
      Exclude(FStates, tsInAnimation);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.CalculateSelectionRect(X, Y: Integer): Boolean;

// Recalculates old and new selection rectangle given that X, Y are new mouse coordinates.
// Returns True if there was a change since the last call.

var
  MaxValue: Integer;

begin
  if tsDrawSelecting in FStates then
    FLastSelRect := FNewSelRect;
  FNewSelRect.BottomRight := Point(X - FOffsetX, Y - FOffsetY);
  if FNewSelRect.Right < 0 then
    FNewSelRect.Right := 0;
  if FNewSelRect.Bottom < 0 then
    FNewSelRect.Bottom := 0;
  MaxValue := ClientWidth;
  if FRangeX > Cardinal(MaxValue) then
    MaxValue := FRangeX;
  if FNewSelRect.Right > MaxValue then
    FNewSelRect.Right := MaxValue;
  MaxValue := ClientHeight;
  if FRangeY > Cardinal(MaxValue) then
    MaxValue := FRangeY;
  if FNewSelRect.Bottom > MaxValue then
    FNewSelRect.Bottom := MaxValue;
    
  Result := not CompareMem(@FLastSelRect, @FNewSelRect, SizeOf(FNewSelRect));
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.CanAutoScroll: Boolean;

// Determines if auto scrolling is currently allowed.

begin
  // Don't scroll the client area if the header is currently doing tracking or dragging.
  // Do auto scroll only if there is a draw selection in progress or the tree is the current drop target or
  // wheel panning/scrolling is active.
  Result := (toAutoScroll in FOptions.FAutoOptions) and (FHeader.FStates = []) and
    (([tsDrawSelPending, tsDrawSelecting] * FStates <> []) or (Assigned(FDragManager) and DragManager.IsDropTarget)) or
    (tsVCLDragging in FStates) or
    ([tsWheelPanning, tsWheelScrolling] * FStates <> []);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.CanEdit(Node: PVirtualNode; Column: Integer): Boolean;

// Returns True if the given node can be edited.

begin
  Result := (toEditable in FOptions.FMiscOptions) and Enabled;
  DoCanEdit(Node, Column, Result);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.CanSelect(Node: PVirtualNode): Boolean; 
begin
  Result:=Assigned(Node);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.CanShowDragImage: Boolean;

// Determines whether a drag image should be shown.

begin
  Result := FDragImageKind <> diNoImage;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.Change(Node: PVirtualNode);

begin
  AdviseChangeEvent(False, Node, crIgnore);

  if FUpdateCount = 0 then
  begin
    if (FChangeDelay > 0) and not (tsSynchMode in FStates) then
      SetTimer(Handle, ChangeTimer, FChangeDelay, nil)
    else
      DoChange(Node);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.CheckParentCheckState(Node: PVirtualNode; NewCheckState: TCheckState): Boolean;

// Checks all siblings of node to determine which check state Node's parent must get.

var
  CheckCount,
  BoxCount: Cardinal;
  PartialCheck: Boolean;
  Run: PVirtualNode;

begin
  CheckCount := 0;
  BoxCount := 0;
  PartialCheck := False;
  Run := Node.Parent.FirstChild;
  while Assigned(Run) do
  begin
    if Run = Node then
    begin
      // The given node cannot be checked because it does not yet have its new check state (as this depends
      // on the outcome of this method). Instead NewCheckState is used as this contains the new state the node
      // will get if this method returns True.
      if Run.CheckType in [ctCheckBox, ctTriStateCheckBox] then
      begin
        Inc(BoxCount);
        if NewCheckState in [csCheckedNormal, csCheckedPressed] then
          Inc(CheckCount);
        PartialCheck := PartialCheck or (NewCheckState = csMixedNormal);
      end;
    end
    else
      if Run.CheckType in [ctCheckBox, ctTriStateCheckBox] then
      begin
        Inc(BoxCount);
        if Run.CheckState in [csCheckedNormal, csCheckedPressed] then
          Inc(CheckCount);
        PartialCheck := PartialCheck or (Run.CheckState = csMixedNormal);
      end;
    Run := Run.NextSibling;
  end;

  if (CheckCount = 0) and not PartialCheck then
    NewCheckState := csUncheckedNormal
  else
    if CheckCount < BoxCount then
      NewCheckState := csMixedNormal
    else                                                        
      NewCheckState := csCheckedNormal;

  Node := Node.Parent;
  Result := DoChecking(Node, NewCheckState);
  if Result then
  begin
    DoCheckClick(Node, NewCheckState);
    // Recursively adjust parent of parent.
    with Node^ do
    begin
      if not (vsInitialized in Parent.States) then
        InitNode(Parent);
      if ([vsChecking, vsDisabled] * Parent.States = []) and (Parent <> FRoot) and
        (Parent.CheckType = ctTriStateCheckBox) then
        Result := CheckParentCheckState(Node, NewCheckState);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.ClearTempCache;

// make sure the temporary node cache is in a reliable state

begin
  FTempNodeCache := nil;
  FTempNodeCount := 0;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.ColumnIsEmpty(Node: PVirtualNode; Column: Integer): Boolean;

// Returns True if the given column is to be considered as being empty. This will usually be determined by
// descentants as the base tree implementation has not enough information to decide.

begin
  Result := False;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.CountLevelDifference(Node1, Node2: PVirtualNode): Integer;

// This method counts how many levels both given nodes are apart. If both nodes have the same parent then the
// difference is 0 otherwise the result is basically GetNodeLevel(Node1) - GetNodeLevel(Node2).
// For optimization, however, we assume some things as this method is mainly designed to be called during
// tree traversal.
// - Node2 can never be more than one level deeper as Node1 (you cannot go two levels down in one step in a valid tree)

begin
  Assert(Assigned(Node1) and Assigned(Node2), 'Both nodes must be Assigned.');

  Result := 0;
  
  if Node2.Parent = Node1 then
  begin
    // Second node is a child node of first one, Node 2 cannot be deeper down by definition.
    Inc(Result);
  end
  else
    // If both nodes have the same parent then they are sibling of each other and we don't need further processing.
    // If the first node a child of the second node then we have to go the parent list of node 1 up so long
    // until we find a common parent. 
    while Node1.Parent <> Node2.Parent do
    begin
      Dec(Result);
      Node1 := Node1.Parent;
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.CountVisibleChildren(Node: PVirtualNode): Cardinal;

// Returns the number of visible child nodes of the given node.
// Note: the given node itself must be visible.

begin
  Assert(vsVisible in Node.States, 'Node must be visible.');

  Result := 0;
  // its direct children
  if vsExpanded in Node.States then
  begin
    // and their children
    Node := Node.FirstChild;
    while Assigned(Node) do
    begin
      if vsVisible in Node.States then
        Inc(Result, CountVisibleChildren(Node) + 1);
      Node := Node.NextSibling;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.CreateParams(var Params: TCreateParams);

const
  ScrollBar: array[TScrollStyle] of Cardinal = (0, WS_HSCROLL, WS_VSCROLL, WS_HSCROLL or WS_VSCROLL);

begin
  inherited CreateParams(Params);
  
  with Params do
  begin
    Style := Style or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or ScrollBar[ScrollBarOptions.FScrollBars];
    if toFullRepaintOnResize in FOptions.MiscOptions then
      WindowClass.style := WindowClass.style or CS_HREDRAW or CS_VREDRAW
    else
      WindowClass.style := WindowClass.style and not (CS_HREDRAW or CS_VREDRAW);
    if FBorderStyle = bsSingle then
    begin
      if Ctl3D then
      begin
        ExStyle := ExStyle or WS_EX_CLIENTEDGE;
        Style := Style and not WS_BORDER;
      end
      else
        Style := Style or WS_BORDER;
    end
    else
      Style := Style and not WS_BORDER;

    // The VCL takes care for RTL window styles but applies them unfortunately only
    // for middle east system locales. Windows 2000+ however can handle them
    // properly too regardless of the system locale.
    if BidiMode <> bdLeftToRight then
      ExStyle := ExStyle or WS_EX_LEFTSCROLLBAR;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.CreateWnd;

// Initializes data which depends on a valid window handle.

begin   
  Include(FStates, tsWindowCreating);
  inherited;
  Exclude(FStates, tsWindowCreating);

  if UseThemes and (toThemeAware in TreeOptions.PaintOptions) then
    Include(FStates, tsUseThemes)
  else
    Exclude(FStates, tsUseThemes);

  if tsUseThemes in FStates then
  begin
    FTreeTheme := OpenThemeData(Handle, 'treeview');
    FButtonTheme := OpenThemeData(Handle, 'button');
    FHeader.Columns.UpdateTheme(Handle);
  end;
    
  // Because of the special recursion and update stopper when creating the window (or resizing it)
  // we have to manually trigger the auto size calculation here.
  if hoAutoResize in FHeader.FOptions then
    FHeader.FColumns.AdjustAutoSize(InvalidColumn);

  // Initialize flat scroll bar library if required.
  {$ifdef UseFlatScrollbars}
    if FScrollBarOptions.FScrollBarStyle <> sbmRegular then
    begin
      InitializeFlatSB(Handle);
      FlatSB_SetScrollProp(Handle, WSB_PROP_HSTYLE, ScrollBarProp[FScrollBarOptions.ScrollBarStyle], False);
      FlatSB_SetScrollProp(Handle, WSB_PROP_VSTYLE, ScrollBarProp[FScrollBarOptions.ScrollBarStyle], False);
    end;
  {$endif UseFlatScrollbars}

  PrepareBitmaps(True, True);

  // Finally register tree as OLE drop target.
  if not (csDesigning in ComponentState) and (toAcceptOLEDrop in FOptions.FMiscOptions) then
    RegisterDragDrop(Handle, DragManager as IDropTarget);

  UpdateScrollBars(True);
  UpdateHeaderRect;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DefineProperties(Filer: TFiler);

// There were heavy changes in some properties during development of VT. This method helps to make migration easier
// by reading old properties manually and put them into the new properties as appropriate.
// Note: these old properties are never written again and silently disappear.

begin
  inherited;

  Filer.DefineProperty('Options', ReadOldOptions, nil, False);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DetermineHitPositionLTR(var HitInfo: THitInfo; Offset, Right: Integer;
  Alignment: TAlignment);

// This method determines the hit position within a node with left-to-right orientation.

var
  MainColumnHit,
  Ghosted: Boolean;
  Run: PVirtualNode;
  Indent,
  TextWidth,
  ImageOffset: Integer;

begin
  MainColumnHit := HitInfo.HitColumn = FHeader.MainColumn;
  Indent := 0;

  // If columns are not used or the main column is hit then the tree indentation must be considered too.
  if MainColumnHit then
  begin
    Run := HitInfo.HitNode;
    while (Run.Parent <> FRoot) do
    begin
      Inc(Indent, FIndent);
      Run := Run.Parent;
    end;
    if toShowRoot in FOptions.FPaintOptions then
      Inc(Indent, FIndent);
  end;

  if Offset < Indent then
  begin
    // Position is to the left of calculated indentation which can only happen for the main column.
    // Check whether it corresponds to a button/checkbox.
    if (toShowButtons in FOptions.FPaintOptions) and (vsHasChildren in HitInfo.HitNode.States) then
    begin
      // Position of button is interpreted very generously to avoid forcing the user
      // to click exactly into the 9x9 pixels area. The entire node height and one full
      // indentation level is accepted as button hit.
      if Offset >= Indent - Integer(FIndent) then
        Include(HitInfo.HitPositions, hiOnItemButton);
    end;
    // no button hit so position is on indent
    if HitInfo.HitPositions = [] then
      Include(HitInfo.HitPositions, hiOnItemIndent);
  end
  else
  begin
    // The next hit positions can be:
    //   - on the check box
    //   - on the state image
    //   - on the normal image
    //   - to the left of the text area
    //   - on the label or
    //   - to the right of the text area
    // (in this order).

    // In report mode no hit other than in the main column is possible.
    if MainColumnHit or not (toReportMode in FOptions.FMiscOptions) then
    begin
      ImageOffset := Indent;
      // Check support is only available for the main column.
      if MainColumnHit and (toCheckSupport in FOptions.FMiscOptions) and Assigned(FCheckImages) and
        (HitInfo.HitNode.CheckType <> ctNone) then
        Inc(ImageOffset, FCheckImages.Width + 2);

      if Offset < ImageOffset then
        HitInfo.HitPositions := [hiOnItem, hiOnItemCheckBox]
      else
      begin
        if Assigned(FStateImages) and (GetImageIndex(HitInfo.HitNode, ikState, HitInfo.HitColumn, Ghosted) > -1) then
          Inc(ImageOffset, FStateImages.Width + 2);
        if Offset < ImageOffset then
          Include(HitInfo.HitPositions, hiOnStateIcon)
        else
        begin
          if Assigned(FImages) and (GetImageIndex(HitInfo.HitNode, ikNormal, HitInfo.HitColumn, Ghosted) > -1) then
            Inc(ImageOffset, FImages.Width + 2);
          if Offset < ImageOffset then
            Include(HitInfo.HitPositions, hiOnNormalIcon)
          else
          begin
            // ImageOffset contains now the left border of the node label area. This is used to calculate the
            // correct alignment in the column.
            TextWidth := DoGetNodeWidth(HitInfo.HitNode, HitInfo.HitColumn);

            // Check if the text can be aligned at all. This is only possible if there is enough room
            // in the remaining text rectangle.
            if TextWidth > Right - ImageOffset then
              Include(HitInfo.HitPositions, hiOnItemLabel)
            else
            begin
              case Alignment of
                taCenter:
                  begin
                    Indent := (ImageOffset + Right - TextWidth) div 2;
                    if Offset < Indent then
                      Include(HitInfo.HitPositions, hiOnItemLeft)
                    else
                      if Offset < Indent + TextWidth then
                        Include(HitInfo.HitPositions, hiOnItemLabel)
                      else
                        Include(HitInfo.HitPositions, hiOnItemRight)
                  end;
                taRightJustify:
                  begin
                    Indent := Right - TextWidth;
                    if Offset < Indent then
                      Include(HitInfo.HitPositions, hiOnItemLeft)
                    else
                      Include(HitInfo.HitPositions, hiOnItemLabel);
                  end;
              else // taLeftJustify
                if Offset < ImageOffset + TextWidth then
                  Include(HitInfo.HitPositions, hiOnItemLabel)
                else
                  Include(HitInfo.HitPositions, hiOnItemRight);
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DetermineHitPositionRTL(var HitInfo: THitInfo; Offset, Right: Integer; Alignment: TAlignment);

// This method determines the hit position within a node with right-to-left orientation.

var
  MainColumnHit,
  Ghosted: Boolean;
  Run: PVirtualNode;
  Indent,
  TextWidth,
  ImageOffset: Integer;

begin
  MainColumnHit := HitInfo.HitColumn = FHeader.MainColumn;

  // If columns are not used or the main column is hit then the tree indentation must be considered too.
  if MainColumnHit then
  begin
    Run := HitInfo.HitNode;
    while (Run.Parent <> FRoot) do
    begin
      Dec(Right, FIndent);
      Run := Run.Parent;
    end;
    if toShowRoot in FOptions.FPaintOptions then
      Dec(Right, FIndent);
  end;

  if Offset >= Right then
  begin
    // Position is to the right of calculated indentation which can only happen for the main column.
    // Check whether it corresponds to a button/checkbox.
    if (toShowButtons in FOptions.FPaintOptions) and (vsHasChildren in HitInfo.HitNode.States) then
    begin
      // Position of button is interpreted very generously to avoid forcing the user
      // to click exactly into the 9x9 pixels area. The entire node height and one full
      // indentation level is accepted as button hit.
      if Offset <= Right + Integer(FIndent) then
        Include(HitInfo.HitPositions, hiOnItemButton);
    end;
    // no button hit so position is on indent
    if HitInfo.HitPositions = [] then
      Include(HitInfo.HitPositions, hiOnItemIndent);
  end
  else
  begin
    // The next hit positions can be:
    //   - on the check box
    //   - on the state image
    //   - on the normal image
    //   - to the left of the text area
    //   - on the label or
    //   - to the right of the text area
    // (in this order).

    // In report mode no hit other than in the main column is possible.
    if MainColumnHit or not (toReportMode in FOptions.FMiscOptions) then
    begin
      ImageOffset := Right;
      // Check support is only available for the main column.
      if MainColumnHit and (toCheckSupport in FOptions.FMiscOptions) and Assigned(FCheckImages) and
        (HitInfo.HitNode.CheckType <> ctNone) then
        Dec(ImageOffset, FCheckImages.Width + 2);

      if Offset > ImageOffset then
        HitInfo.HitPositions := [hiOnItem, hiOnItemCheckBox]
      else
      begin
        if Assigned(FStateImages) and (GetImageIndex(HitInfo.HitNode, ikState, HitInfo.HitColumn, Ghosted) > -1) then
          Dec(ImageOffset, FStateImages.Width + 2);
        if Offset > ImageOffset then
          Include(HitInfo.HitPositions, hiOnStateIcon)
        else
        begin
          if Assigned(FImages) and (GetImageIndex(HitInfo.HitNode, ikNormal, HitInfo.HitColumn, Ghosted) > -1) then
            Dec(ImageOffset, FImages.Width + 2);
          if Offset > ImageOffset then
            Include(HitInfo.HitPositions, hiOnNormalIcon)
          else
          begin
            // ImageOffset contains now the right border of the node label area. This is used to calculate the
            // correct alignment in the column.
            TextWidth := DoGetNodeWidth(HitInfo.HitNode, HitInfo.HitColumn);

            // Check if the text can be aligned at all. This is only possible if there is enough room
            // in the remaining text rectangle.
            if TextWidth > ImageOffset then
              Include(HitInfo.HitPositions, hiOnItemLabel)
            else
            begin
              // Consider bidi mode here. In RTL context does left alignment actually mean right alignment
              // and vice versa.
              ChangeBiDiModeAlignment(Alignment);

              case Alignment of
                taCenter:
                  begin
                    Indent := (ImageOffset - TextWidth) div 2;
                    if Offset < Indent then
                      Include(HitInfo.HitPositions, hiOnItemLeft)
                    else
                      if Offset < Indent + TextWidth then
                        Include(HitInfo.HitPositions, hiOnItemLabel)
                      else
                        Include(HitInfo.HitPositions, hiOnItemRight)
                  end;
                taRightJustify:
                  begin
                    Indent := ImageOffset - TextWidth;
                    if Offset < Indent then
                      Include(HitInfo.HitPositions, hiOnItemLeft)
                    else
                      Include(HitInfo.HitPositions, hiOnItemLabel);
                  end;
              else // taLeftJustify
                if Offset > TextWidth then
                  Include(HitInfo.HitPositions, hiOnItemRight)
                else
                  Include(HitInfo.HitPositions, hiOnItemLabel);
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.DetermineScrollDirections(X, Y: Integer): TScrollDirections;

// Determines which direction the client area must be scrolled depending on the given position.

begin
  Result:= [];

  if CanAutoScroll then
  begin
    // Calculation for wheel panning/scrolling is a bit different to normal auto scroll.
    if [tsWheelPanning, tsWheelScrolling] * FStates <> [] then
    begin
      if (X - FLastClickPos.X) < -8 then
        Include(Result, sdLeft);
      if (X - FLastClickPos.X) > 8 then
        Include(Result, sdRight);

      if (Y - FLastClickPos.Y) < -8 then
        Include(Result, sdUp);
      if (Y - FLastClickPos.Y) > 8 then
        Include(Result, sdDown);
    end
    else
    begin
      if (X < Integer(FDefaultNodeHeight)) and (FOffsetX <> 0) then
        Include(Result, sdLeft);
      if (ClientWidth - FOffsetX < Integer(FRangeX)) and (X > ClientWidth - Integer(FDefaultNodeHeight)) then
        Include(Result, sdRight);

      if (Y < Integer(FDefaultNodeHeight)) and (FOffsetY <> 0) then
        Include(Result, sdUp);
      if (ClientHeight - FOffsetY < Integer(FRangeY)) and (Y > ClientHeight - Integer(FDefaultNodeHeight)) then
        Include(Result, sdDown);

      // Since scrolling during dragging is not handled via the timer we do a check here whether the auto
      // scroll timeout already has elapsed or not.
      if (Result <> []) and
        ((Assigned(FDragManager) and DragManager.IsDropTarget) or
        (FindDragTarget(Point(X, Y), False) = Self)) then
      begin
        if FDragScrollStart = 0 then
          FDragScrollStart := timeGetTime;
        // Reset any scroll direction to avoid scroll in the case the user is dragging and the auto scroll time has not
        // yet elapsed.
        if ((timeGetTime - FDragScrollStart) < FAutoScrollDelay) then
          Result := [];
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoAfterCellPaint(Canvas: TCanvas; Node: PVirtualNode; Column: Integer; CellRect: TRect);

begin
  if Assigned(FOnAfterCellPaint) then
    FOnAfterCellPaint(Self, Canvas, Node, Column, CellRect);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoAfterItemErase(Canvas: TCanvas; Node: PVirtualNode; ItemRect: TRect);

begin
  if Assigned(FOnAfterItemErase) then
    FOnAfterItemErase(Self, Canvas, Node, ItemRect);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoAfterItemPaint(Canvas: TCanvas; Node: PVirtualNode; ItemRect: TRect);

begin
  if Assigned(FOnAfterItemPaint) then
    FOnAfterItemPaint(Self, Canvas, Node, ItemRect);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoAfterPaint(Canvas: TCanvas);

begin
  if Assigned(FOnAfterPaint) then
    FOnAfterPaint(Self, Canvas);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoAutoScroll(X, Y: Integer);

begin
  FScrollDirections := DetermineScrollDirections(X, Y);

  if FStates * [tsWheelPanning, tsWheelScrolling] = [] then
  begin
    if FScrollDirections = [] then
    begin
      if ((FStates * [tsScrollPending, tsScrolling]) <> []) then
      begin
        StopTimer(ScrollTimer);
        FStates := FStates - [tsScrollPending, tsScrolling];
      end;
    end
    else
    begin
      // start auto scroll if not yet done
      if (FStates * [tsScrollPending, tsScrolling]) = [] then
      begin
        Include(FStates, tsScrollPending);
        SetTimer(Handle, ScrollTimer, FAutoScrollDelay, nil);
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.DoBeforeDrag(Node: PVirtualNode; Column: Integer): Boolean;

begin
  Result := False;
  if Assigned(FOnDragAllowed) then
    FOnDragAllowed(Self, Node, Column, Result);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoBeforeCellPaint(Canvas: TCanvas; Node: PVirtualNode; Column: Integer; CellRect: TRect);

begin
  if Assigned(FOnBeforeCellPaint) then
    FOnBeforeCellPaint(Self, Canvas, Node, Column, CellRect);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoBeforeItemErase(Canvas: TCanvas; Node: PVirtualNode; ItemRect: TRect; var Color: TColor;
  var EraseAction: TItemEraseAction);

begin
  if Assigned(FOnBeforeItemErase) then
    FOnBeforeItemErase(Self, Canvas, Node, ItemRect, Color, EraseAction);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.DoBeforeItemPaint(Canvas: TCanvas; Node: PVirtualNode; ItemRect: TRect): Boolean;

begin
  // By default custom draw will not be used, so the tree handles drawing the node.
  Result := False;
  if Assigned(FOnBeforeItemPaint) then
    FOnBeforeItemPaint(Self, Canvas, Node, ItemRect, Result);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoBeforePaint(Canvas: TCanvas);

begin
  if Assigned(FOnBeforePaint) then
    FOnBeforePaint(Self, Canvas);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.DoCancelEdit: Boolean;

// Called when the current edit action or a pending edit must be cancelled.

begin
  StopTimer(EditTimer);
  Exclude(FStates, tsEditPending);
  Result := (tsEditing in FStates) and FEditLink.CancelEdit;
  if Result then
  begin
    Exclude(FStates, tsEditing);
    if Assigned(FOnEditCancelled) then
      FOnEditCancelled(Self, FEditColumn);
    if not (csDestroying in ComponentState) then
    begin
      if CanFocus then
        SetFocus;
      // Asynchroniously release edit link.
      PostMessage(Handle, WM_RELEASEEDITLINK, 0, 0);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoCanEdit(Node: PVirtualNode; Column: Integer; var Allowed: Boolean);

begin
  if Assigned(FOnEditing) then
    FOnEditing(Self, Node, Column, Allowed);
end;
 
//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoChange(Node: PVirtualNode);

begin
  StopTimer(ChangeTimer);
  if Assigned(FOnChange) then
    FOnChange(Self, Node);

  // This is a good place to reset the cached node. This is the same as the node passed in here.
  // This is necessary to allow descentants to override this method and get the node then.
  Exclude(FStates, tsChangePending);
  FLastChangedNode := nil;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoCheckClick(Node: PVirtualNode; NewCheckState: TCheckState);

begin
  if ChangeCheckState(Node, NewCheckState) then
    DoChecked(Node);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoChecked(Node: PVirtualNode);

begin
  if Assigned(FOnChecked) then
    FOnChecked(Self, Node);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.DoChecking(Node: PVirtualNode; var NewCheckState: TCheckState): Boolean;

// Determines if a node is allowed to change its check state to NewCheckState.

begin
  Result := True;
  if Assigned(FOnChecking) then
    FOnChecking(Self, Node, NewCheckState, Result);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoCollapsed(Node: PVirtualNode);

begin
  if Assigned(FOnCollapsed) then
    FOnCollapsed(Self, Node);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.DoCollapsing(Node: PVirtualNode): Boolean;

begin
  Result := True;
  if Assigned(FOnCollapsing) then
    FOnCollapsing(Self, Node, Result);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoColumnClick(Column: Integer; Shift: TShiftState);

begin
  if Assigned(FOnColumnClick) then
    FOnColumnClick(Self, Column, Shift);
end;                                           

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoColumnDblClick(Column: Integer; Shift: TShiftState);

begin
  if Assigned(FOnColumnDblClick) then
    FOnColumnDblClick(Self, Column, Shift);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoColumnResize(Column: Integer);

var
  R: TRect;

begin 
  if not (csLoading in ComponentState) and HandleAllocated then
  begin
    UpdateHorizontalScrollBar(True);
    // Invalidate client area from the current column all to the right.
    R := ClientRect;
    if not (toAutoSpanColumns in FOptions.FAutoOptions) then
      R.Left := FHeader.Columns[Column].Left;
    InvalidateRect(Handle, @R, False);
    FHeader.Invalidate(FHeader.Columns[Column], True);
    if hsTracking in FHeader.States then
      UpdateWindow(Handle);
    
    UpdateDesigner; // design time only

    if Assigned(FOnColumnResize) then
      FOnColumnResize(FHeader, Column);

    // If the tree is currently in edit state then notify edit link.
    if tsEditing in FStates then
      UpdateEditBounds;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.DoCompare(Node1, Node2: PVirtualNode; Column: Integer): Integer;

begin
  Result := 0;
  if Assigned(FOnCompareNodes) then
    FOnCompareNodes(Self, Node1, Node2, Column, Result);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.DoCreateDataObject: IDataObject;

begin
  Result := nil;
  if Assigned(FOnCreateDataObject) then
    FOnCreateDataObject(Self, Result);
end;
                
//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.DoCreateDragManager: IVTDragManager;

begin
  Result := nil;
  if Assigned(FOnCreateDragManager) then
    FOnCreateDragManager(Self, Result);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.DoCreateEditor(Node: PVirtualNode; Column: Integer): IVTEditLink;

begin
  Result := nil;
  if Assigned(FOnCreateEditor) then
  begin
    FOnCreateEditor(Self, Node, Column, Result);
    if Result = nil then
      ShowError(SEditLinkIsNil, hcTFEditLinkIsNil);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoDragging(P: TPoint);

// Initiates finally the drag'n drop operation and returns after DD is finished.

  //--------------- local function --------------------------------------------

  function GetDragOperations: Integer;

  begin
    if FDragOperations = [] then
      Result := DROPEFFECT_COPY or DROPEFFECT_MOVE or DROPEFFECT_LINK
    else
    begin
      Result := 0;
      if doCopy in FDragOperations then
        Result := Result or DROPEFFECT_COPY;
      if doLink in FDragOperations then
        Result := Result or DROPEFFECT_LINK;
      if doMove in FDragOperations then
        Result := Result or DROPEFFECT_MOVE;
    end;
  end;

  //--------------- end local function ----------------------------------------

var
  I,
  DragEffect,
  AllowedEffects: Integer;
  DragObject: TDragObject;

  DataObject: IDataObject;

begin
  DataObject := nil;
  // Dragging is dragging, nothing else.
  DoCancelEdit;

  if Assigned(FCurrentHotNode) then
  begin
    InvalidateNode(FCurrentHotNode);
    FCurrentHotNode := nil;
  end;
  // Select the focused node if not already done.
  if Assigned(FFocusedNode) and not (vsSelected in FFocusedNode.States) then
  begin
    InternalAddToSelection(FFocusedNode, False);
    InvalidateNode(FFocusedNode);
  end;

  UpdateWindow(Handle);

  // Keep a list of all currently selected nodes as this list might change,
  // but we have probably to delete currently selected nodes.
  FDragSelection := GetSortedSelection(True);
  try
    FStates := FStates + [tsOLEDragging] - [tsOLEDragPending, tsClearPending];

    // An application might create a drag object like used during VCL dd. This is not required for OLE dd but
    // required as parameter. 
    DragObject := nil;
    DoStartDrag(DragObject);
    DragObject.Free;

    DataObject := DragManager.DataObject;
    PrepareDragImage(P, DataObject);

    FLastDropMode := dmOnNode;
    // Don't forget to initialize the result. It might never be touched.
    DragEffect := DROPEFFECT_NONE;
    AllowedEffects := GetDragOperations;
    try
      ActiveX.DoDragDrop(DataObject , DragManager as IDropSource, AllowedEffects, DragEffect);
    finally
      GetCursorPos(P);
      P := ScreenToClient(P);
      DoEndDrag(Self, P.X, P.Y);

      FDragImage.EndDrag;

      // Finish the operation.
      if (DragEffect = DROPEFFECT_MOVE) and (toAutoDeleteMovedNodes in TreeOptions.AutoOptions) then
      begin
        // The operation was a move so delete the previously selected nodes.
        BeginUpdate;
        try
          // The list of selected nodes was retrieved in resolved state. That means there can never be a node
          // in the list whose parent (or its parent etc.) is also selected. 
          for I := 0 to High(FDragSelection) do
            DeleteNode(FDragSelection[I]);
        finally
          EndUpdate;
        end;
      end;

      Exclude(FStates, tsOLEDragging);
    end;
  finally
    FDragSelection := nil;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoDragExpand;

var
  SourceTree: TBaseVirtualTree;
  
begin
  StopTimer(ExpandTimer);
  if Assigned(FDropTargetNode) and (vsHasChildren in FDropTargetNode.States) and
    not (vsExpanded in FDropTargetNode.States) then
  begin
    if Assigned(FDragManager) then
      SourceTree := DragManager.DragSource
    else
      SourceTree := nil;

    if not DragManager.DropTargetHelperSupported and Assigned(SourceTree) then
      SourceTree.FDragImage.HideDragImage;
    ToggleNode(FDropTargetNode);
    UpdateWindow(Handle);
    if not DragManager.DropTargetHelperSupported and Assigned(SourceTree) then
      SourceTree.FDragImage.ShowDragImage;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.DoDragOver(Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
  var Effect: Integer): Boolean;

begin
  Result := False;
  if Assigned(FOnDragOver) then
    FOnDragOver(Self, Source, Shift, State, Pt, Mode, Effect, Result);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoDragDrop(Source: TObject; DataObject: IDataObject; Formats: TFormatArray;
  Shift: TShiftState; Pt: TPoint; var Effect: Integer; Mode: TDropMode);

begin
  if Assigned(FOnDragDrop) then
    FOnDragDrop(Self, Source, DataObject, Formats, Shift, Pt, Effect, Mode);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoHeaderDraw(Canvas: TCanvas; Column: TVirtualTreeColumn; R: TRect; Hover, Pressed: Boolean;
  DropMark: TVTDropMarkMode);

begin
  if Assigned(FOnHeaderDraw) then
    FOnHeaderDraw(FHeader, Canvas, Column, R, Hover, Pressed, DropMark);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoEdit;

begin
  StopTimer(ScrollTimer);
  StopTimer(EditTimer);
  Exclude(FStates, tsEditPending);
  if Assigned(FFocusedNode) and not (vsDisabled in FFocusedNode.States) then
  begin
    FEditLink := DoCreateEditor(FFocusedNode, FEditColumn);
    if Assigned(FEditLink) then
    begin
      ScrollIntoView(FFocusedNode, True);
      Include(FStates, tsEditing);
      if FEditLink.PrepareEdit(Self, FFocusedNode, FEditColumn) then
      begin
        UpdateEditBounds;
        // Node needs repaint because the selection rectangle and static text must disappear.
        InvalidateNode(FFocusedNode);
        if not FEditLink.BeginEdit then
          Exclude(FStates, tsEditing);
      end
      else
        Exclude(FStates, tsEditing);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoEndDrag(Target: TObject; X, Y: Integer);

// Do some housekeeping;

begin
  inherited;
  DragFinished;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.DoEndEdit: Boolean;

begin
  Result := (tsEditing in FStates) and FEditLink.EndEdit;
  if Result then
  begin
    Exclude(FStates, tsEditing);
    if CanFocus then
      SetFocus;
    // asynchronously release edit link
    PostMessage(Handle, WM_RELEASEEDITLINK, 0, 0);
    if Assigned(FOnEdited) then
      FOnEdited(Self, FFocusedNode, FEditColumn);
  end;
  Exclude(FStates, tsEditPending);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoExpanded(Node: PVirtualNode);

begin
  if Assigned(FOnExpanded) then
    FOnExpanded(Self, Node);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.DoExpanding(Node: PVirtualNode): Boolean;

begin
  Result := True;
  if Assigned(FOnExpanding) then
    FOnExpanding(Self, Node, Result);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoFocusChange(Node: PVirtualNode; Column: Integer);

begin
  if Assigned(FOnFocusChanged) then
    FOnFocusChanged(Self, Node, Column);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.DoFocusChanging(OldNode, NewNode: PVirtualNode; OldColumn, NewColumn: Integer): Boolean;

begin
  Result := True;
  if Assigned(FOnFocusChanging) then
    FOnFocusChanging(Self, OldNode, NewNode, OldColumn, NewColumn, Result);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoFocusNode(Node: PVirtualNode; Ask: Boolean);

begin
  if not (tsEditing in FStates) or EndEditNode then
  begin
    if Node = FRoot then
      Node := nil;
    if (FFocusedNode <> Node) and (not Ask or DoFocusChanging(FFocusedNode, Node, FFocusedColumn, FFocusedColumn)) then
    begin
      if Assigned(FFocusedNode) then
      begin
        // Do automatic collapsing of last focused node if enabled. This is however only done if
        // old and new focused node have a common parent node.
        if (toAutoExpand in FOptions.FAutoOptions) and Assigned(Node) and (Node.Parent = FFocusedNode.Parent) and
          (vsExpanded in FFocusedNode.States) then
          ToggleNode(FFocusedNode)
        else
          InvalidateNode(FFocusedNode);
      end;
      FFocusedNode := Node;
      // Let explicit assignments take precedence over mouse hover.
      FCurrentHotNode := nil;
    end;

    // Have to scroll the node into view, even it is the same node as before.
    if Assigned(FFocusedNode) then
    begin
      // Make sure a valid column is set if columns are used and no column has currently the focus.
      if FHeader.UseColumns and (FFocusedColumn < 0) then
        FFocusedColumn := 0;
      // Do automatic expansion of the newly focused node if enabled.
      if (toAutoExpand in FOptions.FAutoOptions) and not (vsExpanded in FFocusedNode.States) then
        ToggleNode(FFocusedNode); 
      InvalidateNode(FFocusedNode);
      if FUpdateCount = 0 then
        ScrollIntoView(FFocusedNode, toCenterScrollIntoView in FOptions.SelectionOptions);
    end;

    // Reset range anchor if necessary.
    if FSelectionCount = 0 then
      ResetRangeAnchor; 
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoFreeNode(Node: PVirtualNode);

begin
  if Node = FCurrentHotNode then
    FCurrentHotNode := nil;
  if Assigned(FOnFreeNode) and ([vsInitialized, vsInitialUserData] * Node.States <> []) then
    FOnFreeNode(Self, Node);
  FreeMem(Node);
end;

//----------------------------------------------------------------------------------------------------------------------

// These constants are defined in the platform SDK for W2K/XP, but not yet in Delphi.
const
  SPI_GETTOOLTIPANIMATION = $1016;
  SPI_GETTOOLTIPFADE = $1018;

function TBaseVirtualTree.DoGetAnimationType: THintAnimationType;

// Determines (depending on the properties settings and the system) which hint
// animation type is to be used.

var
  Animation: BOOL;

begin
  Result := FAnimationType;
  if Result = hatSystemDefault then
  begin
    if not IsWinNT then
      Result := hatSlide
    else
    begin
      SystemParametersInfo(SPI_GETTOOLTIPANIMATION, 0, @Animation, 0);
      if not Animation then
        Result := hatNone
      else
      begin
        SystemParametersInfo(SPI_GETTOOLTIPFADE, 0, @Animation, 0);
        if Animation then
          Result := hatFade
        else
          Result := hatSlide;
      end;
    end;
  end;

  // Check availability of MMX if fading is requested.
  if not MMXAvailable and (Result = hatFade) then
    Result := hatSlide;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoGetCursor(var Cursor: TCursor);

begin
  if Assigned(FOnGetCursor) then
    FOnGetCursor(Self, Cursor);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoGetHeaderCursor(var Cursor: HCURSOR);

begin
  if Assigned(FOnGetHeaderCursor) then
    FOnGetHeaderCursor(FHeader, Cursor);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoGetImageIndex(Node: PVirtualNode; Kind: TVTImageKind; Column: Integer;
  var Ghosted: Boolean; var Index: Integer);

begin
  if Assigned(FOnGetImage) then
    FOnGetImage(Self, Node, Kind, Column, Ghosted, Index);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoGetLineStyle(var Bits: Pointer);

begin
  if Assigned(FOnGetLineStyle) then
    FOnGetLineStyle(Self, Bits);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.DoGetNodeHint(Node: PVirtualNode; Column: Integer): WideString;

begin
  Result := Hint;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.DoGetNodeTooltip(Node: PVirtualNode; Column: Integer): WideString;

begin
  Result := Hint;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.DoGetNodeWidth(Node: PVirtualNode; Column: Integer; Canvas: TCanvas = nil): Integer;

begin
  Result := 0;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.DoGetPopupMenu(Node: PVirtualNode; Column: Integer; Position: TPoint): TPopupMenu;

// Queries the application whether there is a node specific popup menu.

var
  Run: PVirtualNode;
  AskParent: Boolean;

begin
  Result := nil;
  if Assigned(FOnGetPopupMenu) then
  begin
    Run := Node;

    if Assigned(Run) then
    begin
      AskParent := True;
      repeat
        FOnGetPopupMenu(Self, Run, Column, Position, AskParent, Result);
        Run := Run.Parent;
      until (Run = FRoot) or Assigned(Result) or not AskParent;
    end
    else
      FOnGetPopupMenu(Self, nil, -1, Position, AskParent, Result);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoGetUserClipboardFormats(var Formats: TFormatEtcArray);

begin
  if Assigned(FOnGetUserClipboardFormats) then
    FOnGetUserClipboardFormats(Self, Formats);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoHeaderClick(Column: Integer; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

begin
  if Assigned(FOnHeaderClick) then
    FOnHeaderClick(FHeader, Column, Button, Shift, X, Y);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoHeaderDblClick(Column: Integer; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

begin
  if Assigned(FOnHeaderDblClick) then
    FOnHeaderDblClick(FHeader, Column, Button, Shift, X, Y);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoHeaderDragged(Column: TColumnIndex; OldPosition: TColumnPosition);

begin
  if Assigned(FOnHeaderDragged) then
    FOnHeaderDragged(FHeader, Column, OldPosition);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.DoHeaderDragging(Column: TColumnIndex): Boolean;

begin
  Result := True;
  if Assigned(FOnHeaderDragging) then
    FOnHeaderDragging(FHeader, Column, Result);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoHeaderMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

begin
  if Assigned(FOnHeaderMouseDown) then
    FOnHeaderMouseDown(FHeader, Button, Shift, X, Y);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoHeaderMouseMove(Shift: TShiftState; X, Y: Integer);

begin
  if Assigned(FOnHeaderMouseMove) then
    FOnHeaderMouseMove(FHeader, Shift, X, Y);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoHeaderMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

begin
  if Assigned(FOnHeaderMouseUp) then
    FOnHeaderMouseUp(FHeader, Button, Shift, X, Y);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoHotChange(Old, New: PVirtualNode);

begin
  if Assigned(FOnHotChange) then
    FOnHotChange(Self, Old, New);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.DoIncrementalSearch(Node: PVirtualNode; const Text: WideString): Integer;

begin
  Result := 0;
  if Assigned(FOnIncrementalSearch) then
    FOnIncrementalSearch(Self, Node, Text, Result);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoInitChildren(Node: PVirtualNode; var ChildCount: Cardinal);

begin
  if Assigned(FOnInitChildren) then
    FOnInitChildren(Self, Node, ChildCount);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoInitNode(Parent, Node: PVirtualNode; var InitStates: TVirtualNodeInitStates);

begin
  if Assigned(FOnInitNode) then
    FOnInitNode(Self, Parent, Node, InitStates);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.DoKeyAction(var CharCode: Word; var Shift: TShiftState): Boolean;

begin
  Result := True;
  if Assigned(FOnKeyAction) then
    FOnKeyAction(Self, CharCode, Shift, Result);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoLoadUserData(Node: PVirtualNode; Stream: TStream);

begin
  if Assigned(FOnLoadNode) then
    if Node = FRoot then
      FOnLoadNode(Self, nil, Stream)
    else
      FOnLoadNode(Self, Node, Stream);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoNodeCopied(Node: PVirtualNode);

begin
  if Assigned(FOnNodeCopied) then
    FOnNodeCopied(Self, Node);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.DoNodeCopying(Node, NewParent: PVirtualNode): Boolean;

begin
  Result := True;
  if Assigned(FOnNodeCopying) then
    FOnNodeCopying(Self, Node, NewParent, Result);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoNodeMoved(Node: PVirtualNode);

begin
  if Assigned(FOnNodeMoved) then
    FOnNodeMoved(Self, Node);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.DoNodeMoving(Node, NewParent: PVirtualNode): Boolean;

begin
  Result := True;
  if Assigned(FOnNodeMoving) then
    FOnNodeMoving(Self, Node, NewParent, Result);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.DoPaintBackground(Canvas: TCanvas; R: TRect): Boolean;

begin
  Result := False;
  if Assigned(FOnPaintBackground) then
    FOnPaintBackground(Self, Canvas, R, Result);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoPaintDropMark(Canvas: TCanvas; Node: PVirtualNode; R: TRect);

// draws the drop mark into the given rectangle
// Note: Changed properties of the given canvas should be reset to their previous values.

var
  SaveBrushColor: TColor;
  SavePenStyle: TPenStyle;

begin
  if FLastDropMode in [dmAbove, dmBelow] then
    with Canvas do
    begin
      SavePenStyle := Pen.Style;
      Pen.Style := psClear;
      SaveBrushColor := Brush.Color;
      Brush.Color := FColors.DropMarkColor;

      if FLastDropMode = dmAbove then
      begin
        Polygon([Point(R.Left + 2, R.Top),
                 Point(R.Right - 2, R.Top),
                 Point(R.Right - 2, R.Top + 6),
                 Point(R.Right - 6, R.Top + 2),
                 Point(R.Left + 6 , R.Top + 2),
                 Point(R.Left + 2, R.Top + 6)
        ]);
      end
      else
        Polygon([Point(R.Left + 2, R.Bottom - 1),
                 Point(R.Right - 2, R.Bottom - 1),
                 Point(R.Right - 2, R.Bottom - 8),
                 Point(R.Right - 7, R.Bottom - 3),
                 Point(R.Left + 7 , R.Bottom - 3),
                 Point(R.Left + 2, R.Bottom - 8)
        ]);
      Brush.Color := SaveBrushColor;
      Pen.Style := SavePenStyle;
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoPaintNode(var PaintInfo: TVTPaintInfo);

begin
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoPopupMenu(Node: PVirtualNode; Column: Integer; Position: TPoint);

// Support for node dependent popup menus.

var
  Menu: TPopupMenu;

begin
  Menu := DoGetPopupMenu(Node, Column, Position);

  if Assigned(Menu) then
  begin
    StopTimer(EditTimer);
    Menu.PopupComponent := Self;
    with ClientToScreen(Position) do
      Menu.Popup(X, Y);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.DoRenderOLEData(const FormatEtcIn: TFormatEtc; out Medium: TStgMedium;
  ForClipboard: Boolean): HRESULT;

begin
  Result := E_FAIL;
  if Assigned(FOnRenderOLEData) then
    FOnRenderOLEData(Self, FormatEtcIn, Medium, ForClipboard, Result);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoReset(Node: PVirtualNode);

begin
  if Assigned(FOnResetNode) then
    FOnResetNode(Self, Node);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoSaveUserData(Node: PVirtualNode; Stream: TStream);

begin
  if Assigned(FOnSaveNode) then
    if Node = FRoot then
      FOnSaveNode(Self, nil, Stream)
    else
      FOnSaveNode(Self, Node, Stream);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoScroll(DeltaX, DeltaY: Integer);

begin
  if Assigned(FOnScroll) then
    FOnScroll(Self, DeltaX, DeltaY);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.DoSetOffsetXY(Value: TPoint; Options: TScrollUpdateOptions; ClipRect: PRect = nil): Boolean;

// Actual offset setter used to scroll the client area, update scroll bars and invalidating the header (all optional).
// Returns True if the offset really changed otherwise False is returned.

var
  DeltaX: Integer;
  DeltaY: Integer;
  DWPStructure: HDWP;
  I: Integer;

begin
  // Range check, order is important here.
  if Value.X < (ClientWidth - Integer(FRangeX)) then
    Value.X := ClientWidth - Integer(FRangeX);
  if Value.X > 0 then
    Value.X := 0;
  DeltaX := Value.X - FOffsetX;
  if Value.Y < (ClientHeight - Integer(FRangeY)) then
    Value.Y := ClientHeight - Integer(FRangeY);
  if Value.Y > 0 then
    Value.Y := 0;
  DeltaY := Value.Y - FOffsetY;

  Result := (DeltaX <> 0) or (DeltaY <> 0);
  if Result then
  begin
    FOffsetX := Value.X;
    FOffsetY := Value.Y;
    Result := True;

    if FUpdateCount = 0 then
    begin
      // The drag image from VCL controls need special consideration.
      if tsVCLDragging in FStates then
        ImageList_DragShowNolock(False);

      if suoScrollClientArea in Options then
      begin
        // Have to invalidate the entire window if there's a background.
        if (toShowBackground in FOptions.FPaintOptions) and (FBackground.Graphic is TBitmap) then
        begin
          // Since we don't use ScrollWindow here we have to move all client windows ourselves.
          DWPStructure := BeginDeferWindowPos(ControlCount);
          for I := 0 to ControlCount - 1 do
            if Controls[I] is TWinControl then
            begin
              with Controls[I] as TWinControl do
                DWPStructure := DeferWindowPos(DWPStructure, Handle, 0, Left + DeltaX, Top + DeltaY, 0, 0,
                  SWP_NOZORDER or SWP_NOACTIVATE or SWP_NOSIZE);
              if DWPStructure = 0 then
                Break;
            end;
          if DWPStructure <> 0 then
            EndDeferWindowPos(DWPStructure);
          InvalidateRect(Handle, nil, False);
        end
        else
        begin
          ScrollWindow(Handle, DeltaX, DeltaY, ClipRect, ClipRect);
        end;
      end;

      if suoUpdateNCArea in Options then
      begin
        if DeltaX <> 0 then
        begin
          if (suoRepaintHeader in Options) and (hoVisible in FHeader.FOptions) then
            FHeader.Invalidate(nil);
          if not (tsSizing in FStates) and (FScrollBarOptions.ScrollBars in [ssHorizontal, ssBoth]) then
            UpdateHorizontalScrollBar(suoRepaintScrollbars in Options);
        end;

        if (DeltaY <> 0) and ([tsThumbTracking, tsSizing] * FStates = []) then
        begin
          UpdateVerticalScrollBar(suoRepaintScrollbars in Options);
          if not (FHeader.UseColumns or IsMouseSelecting) and
            (FScrollBarOptions.ScrollBars in [ssHorizontal, ssBoth]) then
            UpdateHorizontalScrollBar(suoRepaintScrollbars in Options);
        end;
      end;

      if tsVCLDragging in FStates then
        ImageList_DragShowNolock(True);
    end;
    
    DoScroll(DeltaX, DeltaY);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoStructureChange(Node: PVirtualNode; Reason: TChangeReason);

begin
  StopTimer(StructureChangeTimer);
  if Assigned(FOnStructureChange) then
    FOnStructureChange(Self, Node, Reason);

  // This is a good place to reset the cached node and reason. These are the same as the values passed in here.
  // This is necessary to allow descentants to override this method and get them.
  Exclude(FStates, tsStructureChangePending);
  FLastStructureChangeNode := nil;
  FLastStructureChangeReason := crIgnore;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoTimerScroll;

var
  P,
  ClientP: TPoint;
  InRect,
  Panning: Boolean;
  R,
  ClipRect: TRect;
  DeltaX,
  DeltaY: Integer;

begin
  GetCursorPos(P);
  R := ClientRect;
  ClipRect := R;
  MapWindowPoints(Handle, 0, R, 2);
  InRect := PtInRect(R, P);
  ClientP := ScreenToClient(P);
  Panning := [tsWheelPanning, tsWheelScrolling] * FStates <> [];
  
  if IsMouseSelecting or InRect or ([tsWheelPanning, tsWheelScrolling] * FStates <> []) then
  begin
    DeltaX := 0;
    DeltaY := 0;
    if sdUp in FScrollDirections then
    begin
      if Panning then
        DeltaY := FLastClickPos.Y - ClientP.Y - 8
      else
        if InRect then
          DeltaY := Min(FScrollBarOptions.FIncrementY, ClientHeight)
        else
          DeltaY := Min(FScrollBarOptions.FIncrementY, ClientHeight) * Abs(R.Top - P.Y);
      if FOffsetY = 0 then
        Exclude(FScrollDirections, sdUp);
    end;

    if sdDown in FScrollDirections then
    begin
      if Panning then
        DeltaY := FLastClickPos.Y - ClientP.Y + 8
      else
        if InRect then
          DeltaY := -Min(FScrollBarOptions.FIncrementY, ClientHeight)
        else
          DeltaY := -Min(FScrollBarOptions.FIncrementY, ClientHeight) * Abs(P.Y - R.Bottom);
      if (ClientHeight - FOffsetY) = Integer(FRangeY) then
        Exclude(FScrollDirections, sdDown);
    end;

    if sdLeft in FScrollDirections then
    begin
      if Panning then
        DeltaX := FLastClickPos.X - ClientP.X - 8
      else
        if InRect then
          DeltaX := FScrollBarOptions.FIncrementX
        else
          DeltaX := FScrollBarOptions.FIncrementX * Abs(R.Left - P.X);
      if FOffsetX = 0 then
        Exclude(FScrollDirections, sdleft);
    end;

    if sdRight in FScrollDirections then
    begin
      if Panning then
        DeltaX := FLastClickPos.X - ClientP.X + 8
      else
        if InRect then
          DeltaX := -FScrollBarOptions.FIncrementX
        else
          DeltaX := -FScrollBarOptions.FIncrementX * Abs(P.X - R.Right);

      if (ClientWidth - FOffsetX) = Integer(FRangeX) then
        Exclude(FScrollDirections, sdRight);
    end;

    if IsMouseSelecting then
    begin
      // In order to avoid scrolling the area which needs a repaint due to the changed selection rectangle
      // we limit the scroll area explicitely.
      OffsetRect(ClipRect, DeltaX, DeltaY);
      DoSetOffsetXY(Point(FOffsetX + DeltaX, FOffsetY + DeltaY), DefaultScrollUpdateFlags, @ClipRect);
      // When selecting with the mouse then either update only the parts of the window which have been uncovered
      // by the scroll operation if no change in the selection happend or invalidate and redraw the entire
      // client area otherwise (to avoid the time consuming task of determining the display rectangles of every
      // changed node).
      if CalculateSelectionRect(ClientP.X, ClientP.Y) and HandleDrawSelection(ClientP.X, ClientP.Y) then
        InvalidateRect(Handle, nil, False)
      else
      begin
        // The selection did not change so invalidate only the part of the window which really needs an update.
        // 1) Invalidate the parts uncovered by the scroll operation. Add another offset range, we have to
        //    scroll only one stripe but have to update two. 
        OffsetRect(ClipRect, DeltaX, DeltaY);
        SubtractRect(ClipRect, ClientRect, ClipRect);
        InvalidateRect(Handle, @ClipRect, False);

        // 2) Invalidate the selection rectangles.
        UnionRect(ClipRect, OrderRect(FNewSelRect), OrderRect(FLastSelRect));
        OffsetRect(ClipRect, FOffsetX, FOffsetY);
        InvalidateRect(Handle, @ClipRect, False);
      end;
    end
    else
    begin
      // Scroll only if there is no drag'n drop in progress. Drag'n drop scrolling is handled in DragOver.
      if ((FDragManager = nil) or not DragManager.IsDropTarget) and ((DeltaX <> 0) or (DeltaY <> 0)) then
        DoSetOffsetXY(Point(FOffsetX + DeltaX, FOffsetY + DeltaY), DefaultScrollUpdateFlags, nil);
    end;
    UpdateWindow(Handle);

    if (FScrollDirections = []) and ([tsWheelPanning, tsWheelScrolling] * FStates = []) then
    begin
      StopTimer(ScrollTimer);
      FStates := FStates - [tsScrollPending, tsScrolling];
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoUpdating(State: TVTUpdateState);

begin
  if Assigned(FOnUpdating) then
    FOnUpdating(Self, State);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DoValidateCache;

// This method fills the caches used in various situations to speed up search for nodes.
// The strategy is simple: Take the current number of visible nodes and distribute evenly a number of marks
// (which are stored in FPositionCache) so that iterating through the tree doesn't cost too much time.
// If there are less than 'CacheThreshold' nodes in the tree then the cache remains empty (it gets one entry
// which contains a nil node pointer to show the cache has been validated).
// Note: You can adjust the maximum number of nodes between two cache entries by changing CacheThreshold.

var
  EntryCount,
  CurrentTop,
  Index: Cardinal;
  CurrentNode,
  Temp: PVirtualNode;

begin
  FStates := FStates + [tsValidating] - [tsStopValidation, tsUseCache, tsValidationNeeded];
  try
    if FStartIndex = 0 then
      FPositionCache := nil;
    
    if FVisibleCount > CacheThreshold then
    begin
      EntryCount := CalculateCacheEntryCount;
      SetLength(FPositionCache, EntryCount);
      if FStartIndex > EntryCount then
        FStartIndex := EntryCount;

      // Optimize validation by starting with FStartIndex if set.
      if (FStartIndex > 0) and Assigned(FPositionCache[FStartIndex - 1].Node) then
      begin
        // Index is the current entry in FPositionCache.
        Index := FStartIndex - 1;
        // Running term for absolute top value.
        CurrentTop := FPositionCache[Index].AbsoluteTop;
        // Running node pointer.
        CurrentNode := FPositionCache[Index].Node;
      end
      else
      begin
        // Index is the current entry in FPositionCache.
        Index := 0;
        // Running term for absolute top value.
        CurrentTop := 0;
        // Running node pointer.
        CurrentNode := GetFirstVisibleNoInit;
      end;

      Assert(Assigned(CurrentNode), 'DoValidateCache: Internal error. CurrentNode is nil.');

      // EntryCount serves as counter for processed nodes here. This value can always start at 0 as
      // the validation either starts also at index 0 or an index which is always a multiple of CacheThreshold
      // and EntryCount is only used with modulo CacheThreshold.
      EntryCount := 0;
      while not (tsStopValidation in FStates) do
      begin
        if (EntryCount mod CacheThreshold) = 0 then
        begin
          // New cache entry to set up.
          with FPositionCache[Index] do
          begin
            Node := CurrentNode;
            AbsoluteTop := CurrentTop;
          end;
          Inc(Index);
        end;

        Inc(CurrentTop, CurrentNode.NodeHeight);
        // Advance to next visible node.
        Temp := GetNextVisibleNoInit(CurrentNode);
        // If there is no further node or the cache is full then stop the loop.
        if (Temp = nil) or (Integer(Index) = Length(FPositionCache)) then
          Break;

        CurrentNode := Temp;
        Inc(EntryCount);
      end;

      // If there was no further node but the last entry of the cache is not filled yet
      // then take the last node we found.
      if not (tsStopValidation in FStates) and (Integer(Index) = High(FPositionCache)) then
        with FPositionCache[Index] do
        begin
          Node := CurrentNode;
          AbsoluteTop := CurrentTop;
        end;

      // If validation has been stopped then clear the cache as it is likely to be invalid.
      if tsStopValidation in FStates then
        FPositionCache := nil
      else
        Include(FStates, tsUseCache);
    end;

  finally
    FStates := FStates - [tsValidating, tsStopValidation];
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DragCanceled;

// Triggers some housekeeping.

begin
  inherited;
  DragFinished;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.DragDrop(const DataObject: IDataObject; KeyState: Integer; Pt: TPoint;
  var Effect: Integer): HResult;

var
  Shift: TShiftState;
  EnumFormat: IEnumFormatEtc;
  Fetched: Integer;
  OLEFormat: TFormatEtc;
  Formats: TFormatArray;

begin
  StopTimer(ExpandTimer);
  StopTimer(ScrollTimer);
  FStates := FStates - [tsScrollPending, tsScrolling];
  Formats := nil;

  // Ask explicitly again whether the action is allowed. Otherwise we may accept a drop which is intentionally not
  // allowed but cannot be prevented by the application because when the tree was scrolling while dropping
  // no DragOver event is created by the OLE subsystem.
  Result := DragOver(DragManager.DragSource, KeyState, dsDragMove, Pt, Effect);
  try
    if (Result <>  NOERROR) or ((Effect and not DROPEFFECT_SCROLL) = DROPEFFECT_NONE) then
      Result := E_FAIL
    else
    begin
      try
        Shift := KeysToShiftState(KeyState);
        Pt := ScreenToClient(Pt);
        // Determine which formats we can get and pass them along with the data object to the drop handler.
        Result := DataObject.EnumFormatEtc(DATADIR_GET, EnumFormat);
        if Failed(Result) then
          Abort;
        Result := EnumFormat.Reset;
        if Failed(Result) then
          Abort;
        // create a list of available formats
        while EnumFormat.Next(1, OLEFormat, @Fetched) = S_OK do
        begin
          SetLength(Formats, Length(Formats) + 1);
          Formats[High(Formats)] := OLEFormat.cfFormat;
        end;
        DoDragDrop(DragManager.DragSource, DataObject, Formats, Shift, Pt, Effect, FLastDropMode);
      except
        Result := E_UNEXPECTED;
        raise;
      end;
    end;
  finally
    if Assigned(FDropTargetNode) then
    begin
      InvalidateNode(FDropTargetNode);
      FDropTargetNode := nil;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.DragEnter(KeyState: Integer; Pt: TPoint; var Effect: Integer): HResult;

// callback routine for the drop target interface

var
  Shift: TShiftState;
  Accept: Boolean;
  R: TRect;
  HitInfo: THitInfo;

begin
  try
    // Determine acceptance of drag operation and reset scroll start time.
    FDragScrollStart := 0;
    
    Shift := KeysToShiftState(KeyState);
    Pt := ScreenToClient(Pt);
    Effect := SuggestDropEffect(DragManager.DragSource, Shift, Pt, Effect);
    Accept := DoDragOver(DragManager.DragSource, Shift, dsDragEnter, Pt, FLastDropMode, Effect);
    if not Accept then
      Effect := DROPEFFECT_NONE
    else
    begin
      // Set initial drop target node and drop mode.
      GetHitTestInfoAt(Pt.X, Pt.Y, True, HitInfo);
      if Assigned(HitInfo.HitNode) then
      begin
        FDropTargetNode := HitInfo.HitNode;
        R := GetDisplayRect(HitInfo.HitNode, FHeader.MainColumn, False);
        if hiOnItemLabel in HitInfo.HitPositions then
          FLastDropMode := dmOnNode
        else
          if ((R.Top + R.Bottom) div 2) > Pt.Y then
            FLastDropMode := dmAbove
          else
            FLastDropMode := dmBelow;
      end
      else
        FLastDropMode := dmNowhere;
    end;

    // If the drag source is a virtual tree then we know how to control the drag image
    // and can show it even if the source is not the target tree.
    // This is only necessary if we cannot use the drag image helper interfaces.
    if not DragManager.DropTargetHelperSupported and Assigned(DragManager.DragSource) then
      DragManager.DragSource.FDragImage.ShowDragImage;
    Result :=  NOERROR;
  except
    Result := E_UNEXPECTED;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DragFinished;

// Called by DragCancelled or EndDrag to make up for the still missing mouse button up messages.
// These are important for such important things like popup menus.

var
  P: TPoint;
  
begin
  GetCursorPos(P);
  P := ScreenToClient(P);
  if tsRightButtonDown in FStates then
    Perform(WM_RBUTTONUP, 0, Longint(PointToSmallPoint(P)))
  else
    if tsMiddleButtonDown in FStates then
      Perform(WM_MBUTTONUP, 0, Longint(PointToSmallPoint(P)))
    else
      Perform(WM_LBUTTONUP, 0, Longint(PointToSmallPoint(P)));
  FStates := FStates - [tsVCLDragPending, tsVCLDragging];
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DragLeave;

var
  Effect: Integer;

begin
  StopTimer(ExpandTimer);

  if not DragManager.DropTargetHelperSupported and Assigned(DragManager.DragSource) then
    DragManager.DragSource.FDragImage.HideDragImage;

  if Assigned(FDropTargetNode) then
  begin
    InvalidateNode(FDropTargetNode);
    FDropTargetNode := nil;
  end;
  UpdateWindow(Handle);

  Effect := 0;
  DoDragOver(nil, [], dsDragLeave, Point(0, 0), FLastDropMode, Effect);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.DragOver(Source: TObject; KeyState: Integer; DragState: TDragState; Pt: TPoint;
  var Effect: Integer): HResult;

// callback routine for the drop target interface

var
  Shift: TShiftState;
  Accept,
  DragImageWillMove,
  WindowScrolled: Boolean;
  OldR, R: TRect;
  NewDropMode: TDropMode;
  HitInfo: THitInfo;
  DragPos: TPoint;
  Tree: TBaseVirtualTree;
  LastNode: PVirtualNode;

  DeltaX,
  DeltaY: Integer;
  ScrollOptions: TScrollUpdateOptions;

begin
  if not DragManager.DropTargetHelperSupported and (Source is TBaseVirtualTree) then
  begin
    Tree := Source as TBaseVirtualTree;
    ScrollOptions := [suoUpdateNCArea];
  end
  else
  begin
    Tree := nil;
    ScrollOptions := DefaultScrollUpdateFlags;
  end;

  try
    DragPos := Pt;
    Pt := ScreenToClient(Pt);

    // Check if we have to scroll the client area.
    FScrollDirections := DetermineScrollDirections(Pt.X, Pt.Y);
    DeltaX := 0;
    DeltaY := 0;
    if FScrollDirections <> [] then
    begin
      // Determine amount to scroll.
      if sdUp in FScrollDirections then
      begin
        DeltaY := Min(FScrollBarOptions.FIncrementY, ClientHeight);
        if FOffsetY = 0 then
          Exclude(FScrollDirections, sdUp);
      end;
      if sdDown in FScrollDirections then
      begin
        DeltaY := -Min(FScrollBarOptions.FIncrementY, ClientHeight);
        if (ClientHeight - FOffsetY) = Integer(FRangeY) then
          Exclude(FScrollDirections, sdDown);
      end;
      if sdLeft in FScrollDirections then
      begin
        DeltaX := FScrollBarOptions.FIncrementX;
        if FOffsetX = 0 then
          Exclude(FScrollDirections, sdleft);
      end;
      if sdRight in FScrollDirections then
      begin
        DeltaX := -FScrollBarOptions.FIncrementX;
        if (ClientWidth - FOffsetX) = Integer(FRangeX) then
          Exclude(FScrollDirections, sdRight);
      end;
      WindowScrolled := DoSetOffsetXY(Point(FOffsetX + DeltaX, FOffsetY + DeltaY), ScrollOptions, nil);
    end
    else
      WindowScrolled := False;

    // Determine acceptance of drag operation as well as drag target.
    Shift := KeysToShiftState(KeyState);
    GetHitTestInfoAt(Pt.X, Pt.Y, True, HitInfo);
    if Assigned(HitInfo.HitNode) then
    begin
      R := GetDisplayRect(HitInfo.HitNode, NoColumn, False);
      if (hiOnItemLabel in HitInfo.HitPositions) or not (toShowDropmark in FOptions.FPaintOptions) then
        NewDropMode := dmOnNode
      else
        if ((R.Top + R.Bottom) div 2) > Pt.Y then
          NewDropMode := dmAbove
        else
          NewDropMode := dmBelow;
    end
    else
    begin
      NewDropMode := dmNowhere;
      R := Rect(0, 0, 0, 0);
    end;

    if Assigned(Tree) then
      DragImageWillMove := Tree.FDragImage.WillMove(DragPos)
    else
      DragImageWillMove := False;

    if (HitInfo.HitNode <> FDropTargetNode) or (FLastDropMode <> NewDropMode) then
    begin
      // Something in the tree will change. This requires to update the screen and/or the drag image.
      FLastDropMode := NewDropMode;
      if HitInfo.HitNode <> FDropTargetNode then
      begin
        StopTimer(ExpandTimer);
        // The last target node is needed for the rectangle determination but must already be set for
        // the recapture call, hence it must be stored somewhere.
        LastNode := FDropTargetNode;
        FDropTargetNode := HitInfo.HitNode;
        // In order to show a selection rectangle a column must be focused.
        if FFocusedColumn = NoColumn then
          FFocusedColumn := FHeader.MainColumn;

        if Assigned(LastNode) and Assigned(FDropTargetNode) then
        begin
          // Optimize the case that the selection moved between two nodes. 
          OldR := GetDisplayRect(LastNode, NoColumn, False);
          UnionRect(R, R, OldR);
          if Assigned(Tree) then
          begin
            if WindowScrolled then
              UpdateWindowAndDragImage(Tree, ClientRect, True, not DragImageWillMove)
            else
              UpdateWindowAndDragImage(Tree, R, False, not DragImageWillMove);
          end
          else
            InvalidateRect(Handle, @R, False);
        end
        else
        begin
          if Assigned(LastNode) then
          begin
            // Repaint last target node.
            OldR := GetDisplayRect(LastNode, NoColumn, False);
            if Assigned(Tree) then
            begin
              if WindowScrolled then
                UpdateWindowAndDragImage(Tree, ClientRect, WindowScrolled, not DragImageWillMove)
              else
                UpdateWindowAndDragImage(Tree, OldR, False, not DragImageWillMove);
            end
            else
              InvalidateRect(Handle, @OldR, False);
          end
          else
          begin
            if Assigned(Tree) then
            begin
              if WindowScrolled then
                UpdateWindowAndDragImage(Tree, ClientRect, WindowScrolled, not DragImageWillMove)
              else
                UpdateWindowAndDragImage(Tree, R, False, not DragImageWillMove);
            end
            else
              InvalidateRect(Handle, @R, False);
          end;
        end;

        // Start auto expand timer if necessary.
        if (toAutoDropExpand in FOptions.FAutoOptions) and Assigned(FDropTargetNode) and
          (vsHasChildren in FDropTargetNode.States) then
          SetTimer(Handle, ExpandTimer, FAutoExpandDelay, nil);
      end
      else
      begin
        // Only the drop mark position changed so invalidate the current drop target node.
        if Assigned(Tree) then
        begin
          if WindowScrolled then
            UpdateWindowAndDragImage(Tree, ClientRect, WindowScrolled, not DragImageWillMove)
          else
            UpdateWindowAndDragImage(Tree, R, False, not DragImageWillMove);
        end
        else
          InvalidateRect(Handle, @R, False);
      end;
    end
    else
    begin
      // No change in the current drop target or drop mode. This might still mean horizontal or vertical scrolling.
      if Assigned(Tree) and ((DeltaX <> 0) or (DeltaY <> 0)) then
        UpdateWindowAndDragImage(Tree, ClientRect, WindowScrolled, not DragImageWillMove);
    end;

    if Assigned(Tree) and DragImageWillMove then
      Tree.FDragImage.DragTo(DragPos, False);

    Effect := SuggestDropEffect(Source, Shift, Pt, Effect);
    Accept := DoDragOver(Source, Shift, DragState, Pt, FLastDropMode, Effect);
    if not Accept then
      Effect := DROPEFFECT_NONE;
    if WindowScrolled then
      Effect := Effect or Integer(DROPEFFECT_SCROLL);
    Result :=  NOERROR;
  except
    Result := E_UNEXPECTED;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DrawDottedHLine(const PaintInfo: TVTPaintInfo; Left, Right, Top: Integer);

// Draws a horizontal line with alternating pixels (this style is not supported for pens under Win9x).

var
  R: TRect;

begin
  with PaintInfo, Canvas do
  begin
    Brush.Color := Color;
    // We have to reapply the brush alignment setting everytime this method is called because of the VCL's
    // handling of canvas handles.
    SetBrushOrgEx(Handle, BrushOrigin.X, BrushOrigin.Y, nil);
    R := Rect(Min(Left, Right), Top, Max(Left, Right) + 1, Top + 1);
    Windows.FillRect(Handle, R, FDottedBrush);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DrawDottedVLine(const PaintInfo: TVTPaintInfo; Top, Bottom, Left: Integer);

// Draws a horizontal line with alternating pixels (this style is not supported for pens under Win9x).

var
  R: TRect;

begin
  with PaintInfo, Canvas do
  begin
    Brush.Color := Color;
    // We have to reapply the brush alignment setting everytime this method is called because of the VCL's
    // handling of canvas handles.
    SetBrushOrgEx(Handle, BrushOrigin.X, BrushOrigin.Y, nil);
    R := Rect(Left, Min(Top, Bottom), Left + 1, Max(Top, Bottom) + 1);
    Windows.FillRect(Handle, R, FDottedBrush);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.FindNodeInSelection(P: PVirtualNode; var Index: Integer; LowBound,
  HighBound: Integer): Boolean;

// Search routine to find a specific node in the selection array.
// LowBound and HighBound determine the range in which to search the node.
// Either value can be -1 to denote the maximum range otherwise LowBound must be less or equal HighBound.

var
  L, H,
  I, C: Integer;

begin
  Result := False;
  L := 0;
  if LowBound >= 0 then
    L := LowBound;
  H := FSelectionCount - 1;
  if HighBound >= 0 then
    H := HighBound;
  while L <= H do
  begin
    I := (L + H) shr 1;
    C := Integer(FSelection[I]) - Integer(P);
    if C < 0 then
      L := I + 1
    else
    begin
      H := I - 1;
      if C = 0 then
      begin
        Result := True;
        L := I;
      end;
    end;
  end;
  Index := L;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.FinishChunkHeader(Stream: TStream; StartPos, EndPos: Integer);

// used while streaming out a node to finally write out the size of the chunk

var
  Size: Integer;
  
begin
  // seek back to the second entry in the chunk header
  Stream.Position := StartPos + SizeOf(Integer);
  // determine size of chunk without the chunk header
  Size := EndPos - StartPos - SizeOf(TChunkHeader);
  // write the size...
  Stream.Write(Size, SizeOf(Size));
  // ... and seek to the last endposition
  Stream.Position := EndPos;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetCheckImage(Node: PVirtualNode): Integer;

// Determines the index into the check image list for the given node depending on the check type
// and enabled state.

const
  // Four dimensional array consisting of image indices for the check type, the check state, the enabled state and the
  // hot state.
  CheckStateToCheckImage: array[ctCheckBox..ctButton, csUncheckedNormal..csMixedPressed, Boolean, Boolean] of Integer = (
    // ctCheckBox, ctTriStateCheckBox
    (
      // csUncheckedNormal (disabled [not hot, hot], enabled [not hot, hot])
      ((ckCheckUncheckedDisabled, ckCheckUncheckedDisabled), (ckCheckUncheckedNormal, ckCheckUncheckedHot)),
      // csUncheckedPressed (disabled [not hot, hot], enabled [not hot, hot])
      ((ckCheckUncheckedDisabled, ckCheckUncheckedDisabled), (ckCheckUncheckedPressed, ckCheckUncheckedPressed)),
      // csCheckedNormal
      ((ckCheckCheckedDisabled, ckCheckCheckedDisabled), (ckCheckCheckedNormal, ckCheckCheckedHot)),
      // csCheckedPressed
      ((ckCheckCheckedDisabled, ckCheckCheckedDisabled), (ckCheckCheckedPressed, ckCheckCheckedPressed)),
      // csMixedNormal
      ((ckCheckMixedDisabled, ckCheckMixedDisabled), (ckCheckMixedNormal, ckCheckMixedHot)),
      // csMixedPressed
      ((ckCheckMixedDisabled, ckCheckMixedDisabled), (ckCheckMixedPressed, ckCheckMixedPressed))
    ),
    // ctRadioButton
    (
      // csUncheckedNormal (disabled [not hot, hot], enabled [not hot, hot])
      ((ckRadioUncheckedDisabled, ckRadioUncheckedDisabled), (ckRadioUncheckedNormal, ckRadioUncheckedHot)),
      // csUncheckedPressed (disabled [not hot, hot], enabled [not hot, hot])
      ((ckRadioUncheckedDisabled, ckRadioUncheckedDisabled), (ckRadioUncheckedPressed, ckRadioUncheckedPressed)),
      // csCheckedNormal
      ((ckRadioCheckedDisabled, ckRadioCheckedDisabled), (ckRadioCheckedNormal, ckRadioCheckedHot)),
      // csCheckedPressed
      ((ckRadioCheckedDisabled, ckRadioCheckedDisabled), (ckRadioCheckedPressed, ckRadioCheckedPressed)),
      // csMixedNormal (should never appear with ctRadioButton)
      ((ckCheckMixedDisabled, ckCheckMixedDisabled), (ckCheckMixedNormal, ckCheckMixedHot)),
      // csMixedPressed (should never appear with ctRadioButton)
      ((ckCheckMixedDisabled, ckCheckMixedDisabled), (ckCheckMixedPressed, ckCheckMixedPressed))
    ),
    // ctButton
    (
      // csUncheckedNormal (disabled [not hot, hot], enabled [not hot, hot])
      ((ckButtonDisabled, ckButtonDisabled), (ckButtonNormal, ckButtonHot)),
      // csUncheckedPressed (disabled [not hot, hot], enabled [not hot, hot])
      ((ckButtonDisabled, ckButtonDisabled), (ckButtonPressed, ckButtonPressed)),
      // csCheckedNormal
      ((ckButtonDisabled, ckButtonDisabled), (ckButtonNormal, ckButtonHot)),
      // csCheckedPressed
      ((ckButtonDisabled, ckButtonDisabled), (ckButtonPressed, ckButtonPressed)),
      // csMixedNormal (should never appear with ctButton)
      ((ckCheckMixedDisabled, ckCheckMixedDisabled), (ckCheckMixedNormal, ckCheckMixedHot)),
      // csMixedPressed (should never appear with ctButton)
      ((ckCheckMixedDisabled, ckCheckMixedDisabled), (ckCheckMixedPressed, ckCheckMixedPressed))
    )
  );

var
  AType: TCheckType;

begin
  if Node.CheckType = ctNone then
    Result := -1
  else
  begin
    AType := Node.CheckType;
    if AType = ctTriStateCheckBox then
      AType := ctCheckBox;
    Result := CheckStateToCheckImage[AType, Node.CheckState, not (vsDisabled in Node.States) and Enabled,
      Node = FCurrentHotNode];
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetColumnClass: TVirtualTreeColumnClass;

begin
  Result := TVirtualTreeColumn;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetHeaderClass: TVTHeaderClass;

begin
  Result := TVTHeader;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetImageIndex(Node: PVirtualNode; Kind: TVTImageKind; Column: Integer;
  var Ghosted: Boolean): Integer;

begin
  Result := -1;
  Ghosted := False;
  DoGetImageIndex(Node, Kind, Column, Ghosted, Result);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetMaxRightExtend: Cardinal;

// Determines the maximum with of the currently visible part of the tree, depending on the length
// of the node texts. This method is used for determining the horizontal scroll range if no columns are used.

var
  Node,
  NextNode: PVirtualNode;
  TopPosition: Integer;
  NodeLeft,
  CurrentWidth: Integer;
  WithCheck: Boolean;
  CheckOffset: Integer;

begin
  Node := GetNodeAt(0, 0, True, TopPosition);
  Result := 0;
  if toShowRoot in FOptions.FPaintOptions then
    NodeLeft := (GetNodeLevel(Node) + 1) * FIndent
  else
    NodeLeft := GetNodeLevel(Node) * FIndent;
    
  if Assigned(FStateImages) then
    Inc(NodeLeft, FStateImages.Width + 2);
  if Assigned(FImages) then
    Inc(NodeLeft, FImages.Width + 2);
  WithCheck := (toCheckSupport in FOptions.FMiscOptions) and Assigned(FCheckImages);
  if WithCheck then
    CheckOffset := FCheckImages.Width + 2
  else
    CheckOffset := 0;

  while Assigned(Node) do
  begin
    if not (vsInitialized in Node.States) then
      InitNode(Node);

    if WithCheck and (Node.CheckType <> ctNone) then
      Inc(NodeLeft, CheckOffset);
    CurrentWidth := DoGetNodeWidth(Node, NoColumn);
    if Integer(Result) < (NodeLeft + CurrentWidth) then
      Result := NodeLeft + CurrentWidth;
    Inc(TopPosition, Node.NodeHeight);
    if TopPosition > Height then
      Break;

    if WithCheck and (Node.CheckType <> ctNone) then
      Dec(NodeLeft, CheckOffset);

    // Get next visible node and update left node position.
    NextNode := GetNextVisible(Node);
    if NextNode = nil then
      Break;
    Inc(NodeLeft, CountLevelDifference(Node, NextNode) * Integer(FIndent));
    Node := NextNode;
  end;

  Inc(Result, 2 * FMargin);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.GetNativeClipboardFormats(var Formats: TFormatEtcArray);

// Returns the supported clipboard formats of the tree in the native CF_* form as used in IDataObject.

begin
  InternalClipboardFormats.EnumerateFormats(TVirtualTreeClass(ClassType), Formats);

  // Ask application/descentants for self defined formats.
  DoGetUserClipboardFormats(Formats);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetOptionsClass: TTreeOptionsClass;

begin
  Result := TCustomVirtualTreeOptions;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.GetTextInfo(Node: PVirtualNode; Column: Integer; const AFont: TFont; var R: TRect;
  var Text: WideString);

// Generic base method for editors, hint windows etc. to get some info about a node.

begin
  R := Rect(0, 0, 0, 0);
  Text := '';
  AFont.Assign(Font);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetTreeFromDataObject(const DataObject: IDataObject): TBaseVirtualTree;

// Returns the owner/sender of the given data object by means of a special clipboard format
// or nil if the sender is in another process or no virtual tree at all.

var
  Medium: TStgMedium;
  Data: PVTReference;

begin
  Result := nil;
  if Assigned(DataObject) then
  begin
    StandardOLEFormat.cfFormat := CF_VTREFERENCE;
    if DataObject.GetData(StandardOLEFormat, Medium) = S_OK then
    begin
      Data := GlobalLock(Medium.hGlobal);
      if Assigned(Data) then
      begin
        if Data.Process = GetCurrentProcessID then
          Result := Data.Tree;
        GlobalUnlock(Medium.hGlobal);
      end;
      ReleaseStgMedium(Medium);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.HandleHotTrack(X, Y: Integer);

// Updates the current "hot" node.

var
  HitInfo: THitInfo;

begin
  // Get information about the hit.
  GetHitTestInfoAt(X, Y, True, HitInfo);
  // Only make the new node being "hot" if its label is hit or full row selection is enabled.
  if ([hiOnItemLabel, hiOnItemCheckbox] * HitInfo.HitPositions = []) and
    not (toFullRowSelect in FOptions.FSelectionOptions) then
    HitInfo.HitNode := nil;
  if HitInfo.HitNode <> FCurrentHotNode then
  begin
    DoHotChange(FCurrentHotNode, HitInfo.HitNode);
    if Assigned(FCurrentHotNode) then
      InvalidateNode(FCurrentHotNode);
    FCurrentHotNode := HitInfo.HitNode;
    if Assigned(FCurrentHotNode) then
      InvalidateNode(FCurrentHotNode);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.HandleIncrementalSearch(CharCode: Word);

var
  Run, Stop: PVirtualNode;
  GetNextNode: TGetNextNodeProc;
  NewSearchText: WideString;
  SingleLetter: Boolean;

  //--------------- local functions -------------------------------------------

  procedure SetupNavigation;

  // If the search buffer is empty then we start searching with the next node after the last one, otherwise
  // we continue with the last one. Setup node navigation function too, to avoid frequent checks.

  var
    FindNextNode: Boolean;

  begin
    FindNextNode := (Length(FSearchBuffer) = 0) or (Run = nil) or SingleLetter;
    case FIncrementalSearch of
      isVisibleOnly:
        if FSearchDirection = sdForward then
        begin
          GetNextNode := GetNextVisible;
          if FindNextNode then
          begin
            if Run = nil then
              Run := GetFirstVisible
            else
            begin
              Run := GetNextVisible(Run);
              // Do wrap around.
              if Run = nil then
                Run := GetFirstVisible;
            end;
          end;
        end
        else
        begin
          GetNextNode := GetPreviousVisible;
          if FindNextNode then
          begin
            if Run = nil then
              Run := GetLastVisible
            else
            begin
              Run := GetPreviousVisible(Run);
              // Do wrap around.
              if Run = nil then
                Run := GetLastVisible;
            end;
          end;
        end;
      isInitializedOnly:
        if FSearchDirection = sdForward then
        begin
          GetNextNode := GetNextNoInit;
          if FindNextNode then
          begin
            if Run = nil then
              Run := GetFirstNoInit
            else
            begin
              Run := GetNextNoInit(Run);
              // Do wrap around.
              if Run = nil then
                Run := GetFirstNoInit;
            end;
          end;
        end
        else
        begin
          GetNextNode := GetPreviousNoInit;
          if FindNextNode then
          begin
            if Run = nil then
              Run := GetLastNoInit
            else
            begin
              Run := GetPreviousNoInit(Run);
              // Do wrap around.
              if Run = nil then
                Run := GetLastNoInit;
            end;
          end;
        end;
    else
      // isAll
      if FSearchDirection = sdForward then
      begin
        GetNextNode := GetNext;
        if FindNextNode then
        begin
          if Run = nil then
            Run := GetFirst
          else
          begin
            Run := GetNext(Run);
            // Do wrap around.
            if Run = nil then
              Run := GetFirst;
          end;
        end;
      end
      else
      begin
        GetNextNode := GetPrevious;
        if FindNextNode then
        begin
          if Run = nil then
            Run := GetLast
          else
          begin
            Run := GetPrevious(Run);
            // Do wrap around.
            if Run = nil then
              Run := GetLast;
          end;
        end;
      end;
    end;
  end;

  //---------------------------------------------------------------------------

  function CodePageFromLocale(Language: LCID): Integer;

  // Determines the code page for a given locale.
  // Unfortunately there is no easier way than this.

  var
    Buf: array[0..6] of Char;

  begin
    GetLocaleInfo(Language, LOCALE_IDEFAULTANSICODEPAGE, Buf, 6);
    Result := StrToIntDef(Buf, GetACP);
  end;

  //---------------------------------------------------------------------------

  function KeyUnicode(C: Char): WideChar;

  // Converts the given character into its corresponding Unicode character
  // depending on the active keyboard layout.

  begin
    MultiByteToWideChar(CodePageFromLocale(GetKeyboardLayout(0) and $FFFF),
      MB_USEGLYPHCHARS, @C, 1, @Result, 1);
  end;

  //--------------- end local functions ---------------------------------------

var
  FoundMatch: Boolean;
  NewChar: WideChar;

begin
  StopTimer(SearchTimer);

  if FIncrementalSearch <> isNone then
  begin
    if CharCode <> 0 then
    begin
      Include(FStates, tsIncrementalSearching);

      // Convert the given virtual key code into a Unicode character based on the current locale.
      NewChar := KeyUnicode(Char(CharCode));
      
      // Determine which method to use to advance nodes and the start node to search from.
      case FSearchStart of
        ssAlwaysStartOver:
          Run := nil;
        ssFocusedNode:
          Run := FFocusedNode;
      else // ssLastHit
        Run := FLastSearchNode;
      end;

      // Make sure the start node corresponds to the search criterion.
      if Assigned(Run) then
      begin
        case FIncrementalSearch of
          isInitializedOnly:
            if not (vsInitialized in Run.States) then
              Run := nil;
          isVisibleOnly:
            if not FullyVisible[Run] then
              Run := nil;
        end;
      end;
      Stop := Run;
      // The "single letter mode" is used to advance quickly from node to node when pressing the same key several times.
      SingleLetter := (Length(FSearchBuffer) = 1) and (FSearchBuffer[1] = NewChar);
      SetupNavigation;
      FoundMatch := False;

      if Assigned(Run) then
      begin
        if SingleLetter then
          NewSearchText := FSearchBuffer
        else
          NewSearchText := FSearchBuffer + NewChar;
        if FIncrementalSearch = isInitializedOnly then
        begin
          repeat
            if DoIncrementalSearch(Run, NewSearchText) = 0 then
            begin
              FoundMatch := True;
              Break;
            end;

            // Advance to next node if we have not found a match.
            Run := GetNextNode(Run);
            // Do wrap around start or end of tree.
            if (Run <> Stop) and (Run = nil) then
              SetupNavigation;
          until Run = Stop;
        end
        else
        begin
          repeat
            if DoIncrementalSearch(Run, NewSearchText) = 0 then
            begin
              FoundMatch := True;
              Break;
            end;

            Run := GetNextNode(Run);
            // Do wrap around start or end of tree.
            if (Run <> Stop) and (Run = nil) then
              SetupNavigation;
          until Run = Stop;
        end;
      end;
      
      if FoundMatch then
      begin
        ClearSelection;
        FSearchBuffer := NewSearchText;
        FLastSearchNode := Run;
        FocusedNode := Run;
        Selected[Run] := True;
        FLastSearchNode := Run;
      end
      else
        // Play an acoustic signal if nothing could be found but don't beep if only the currently
        // focused node matches.
        if Assigned(Run) and (DoIncrementalSearch(Run, NewSearchText) <> 0) then
          Beep;
    end;

    // Restart search timeout interval.
    SetTimer(Handle, SearchTimer, FSearchTimeout, nil);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.HandleMouseDblClick(var Message: TWMMouse; const HitInfo: THitInfo);

var
  NewCheckState: TCheckState;

begin
  if tsEditPending in FStates then
  begin
    StopTimer(EditTimer);
    Exclude(FStates, tsEditPending);
  end;

  if not (tsEditing in FStates) or DoEndEdit then
  begin
    if HitInfo.HitColumn = FHeader.FColumns.FClickIndex then
      DoColumnDblClick(HitInfo.HitColumn, KeysToShiftState(Message.Keys));

    if hiOnItemCheckBox in HitInfo.HitPositions then
    begin
      if (FCheckNode = nil) and not (vsDisabled in HitInfo.HitNode.States) then
      begin
        with HitInfo.HitNode^ do
          NewCheckState := DetermineNextCheckState(CheckType, CheckState);
        if DoChecking(HitInfo.HitNode, NewCheckState) then
        begin
          FCheckNode := HitInfo.HitNode;
          FPendingCheckState := NewCheckState;
          FCheckNode.CheckState := PressedState[FCheckNode.CheckState];
          InvalidateNode(HitInfo.HitNode);
        end;
      end;
    end
    else
    begin
      if hiOnItemButton in HitInfo.HitPositions then
        ToggleNode(HitInfo.HitNode)
      else
      begin
        if toToggleOnDblClick in FOptions.FMiscOptions then
        begin
          if ((([hiOnItemButton, hiOnItemLabel, hiOnNormalIcon, hiOnStateIcon] * HitInfo.HitPositions) <> []) or
            ((toFullRowSelect in FOptions.FSelectionOptions) and Assigned(HitInfo.HitNode))) then
            ToggleNode(HitInfo.HitNode);
        end;
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.HandleMouseDown(var Message: TWMMouse; const HitInfo: THitInfo);

// centralized mouse button down handling

var
  LastFocused: PVirtualNode;
  Column: Integer;
  ShiftState: TShiftState;

  // helper variables to shorten boolean equations/expressions
  AutoDrag,              // automatic (or allowed) drag start
  IsHit,                 // the node's caption or images are hit
  IsCellHit,             // for grid extension or full row select (but not check box, button)
  IsAnyHit,              // either IsHit or IsCellHit
  MultiSelect,           // multiselection is enabled
  ShiftEmpty,            // ShiftState = []
  NodeSelected: Boolean; // the new node (if any) is selected
  NewColumn: Boolean;    // column changed
  NeedChange: Boolean;   // change event is required for selection change
  CanClear: Boolean;     
  NewCheckState: TCheckState;

begin
  if [tsWheelPanning, tsWheelScrolling] * FStates <> [] then
  begin
    StopWheelPanning;
    Exit;
  end;

  if tsEditPending in FStates then
  begin
    StopTimer(EditTimer);
    Exclude(FStates, tsEditPending);
  end;

  if not (tsEditing in FStates) or DoEndEdit then
  begin
    // Keep clicked column in case the application needs it.
    FHeader.FColumns.FClickIndex := HitInfo.HitColumn;
  
    // Change column only if we have hit the node label.
    if (hiOnItemLabel in HitInfo.HitPositions) or
      (toFullRowSelect in FOptions.FSelectionOptions) or
      (toGridExtensions in FOptions.FMiscOptions) then
    begin
      NewColumn := FFocusedColumn <> HitInfo.HitColumn;
      if toExtendedFocus in FOptions.FSelectionOptions then
        Column := HitInfo.HitColumn
      else
        Column := FHeader.MainColumn;
    end
    else
    begin
      NewColumn := False;
      Column := FFocusedColumn;
    end;

    // Translate keys and filter out shift and control key.
    ShiftState := KeysToShiftState(Message.Keys) * [ssShift, ssCtrl];

    // Various combinations determine what states the tree enters now.
    // We initialize shorthand variables to avoid the following expressions getting too large
    // and to avoid repeative expensive checks.
    IsHit := (hiOnItemLabel in HitInfo.HitPositions) or (hiOnNormalIcon in HitInfo.HitPositions);
    IsCellHit := not IsHit and Assigned(HitInfo.HitNode) and
      ([hiOnItemButton, hiOnItemCheckBox] * HitInfo.HitPositions = []) and
      ((toFullRowSelect in FOptions.FSelectionOptions) or (toGridExtensions in FOptions.FMiscOptions)); 
    IsAnyHit := IsHit or IsCellHit;
    MultiSelect := toMultiSelect in FOptions.FSelectionOptions;
    ShiftEmpty := ShiftState = [];
    NodeSelected := IsAnyHit and (vsSelected in HitInfo.HitNode.States);

    // Dragging might be started in the inherited handler manually (which is discouraged for stability reasons)
    // the test for manual mode is done below (after the focused node is set).
    AutoDrag := ((DragMode = dmAutomatic) or Dragging) and not IsCellHit;

    // Query the application to learn if dragging may start now (if set to dmManual).
    if Assigned(HitInfo.HitNode) and not AutoDrag and (DragMode = dmManual) then
      AutoDrag := DoBeforeDrag(HitInfo.HitNode, Column) and not IsCellHit;

    // handle button clicks
    if (hiOnItemButton in HitInfo.HitPositions) and (vsHasChildren in HitInfo.HitNode.States) then
    begin
      ToggleNode(HitInfo.HitNode);
      Exit;
    end;

    // check event
    if hiOnItemCheckBox in HitInfo.HitPositions then
    begin
      if (FCheckNode = nil) and not (vsDisabled in HitInfo.HitNode.States) then
      begin
        with HitInfo.HitNode^ do
          NewCheckState := DetermineNextCheckState(CheckType, CheckState);
        if DoChecking(HitInfo.HitNode, NewCheckState) then
        begin
          FCheckNode := HitInfo.HitNode;
          FPendingCheckState := NewCheckState;
          FCheckNode.CheckState := PressedState[FCheckNode.CheckState];
          InvalidateNode(HitInfo.HitNode);
        end;
      end;
      Exit;
    end;

    // Keep this node's level in case we need it for constraint selection.
    if (FRoot.ChildCount > 0) and ShiftEmpty or (FSelectionCount = 0) then
      if Assigned(HitInfo.HitNode) then
        FLastSelectionLevel := GetNodeLevel(HitInfo.HitNode)
      else
        FLastSelectionLevel := GetNodeLevel(GetLastVisibleNoInit);

    // pending clearance
    if MultiSelect and ShiftEmpty and not (hiOnItemCheckbox in HitInfo.HitPositions) and
       (IsHit and ShiftEmpty and AutoDrag and NodeSelected) then
      Include(FStates, tsClearPending);

    // immediate clearance
    // Determine for the right mouse button if there is a popup menu. In this case and if drag'n drop is pending
    // the current selection has to stay as it is.
    with HitInfo, Message do
      CanClear := not AutoDrag and
        (not (tsRightButtonDown in FStates) or not HasPopupMenu(HitNode, HitColumn, Point(XPos, YPos)));
    if (not IsAnyHit and MultiSelect and ShiftEmpty) or
      (IsAnyHit and (not NodeSelected or (NodeSelected and CanClear)) and (ShiftEmpty or not MultiSelect)) then
    begin
      Assert(not (tsClearPending in FStates), 'Pending and direct clearance are mutual exclusive!');
      if NodeSelected then
      begin
        // If the currently hit node is (also) selected then we have to reselect it again but without
        // a change event if it is the only selected node.
        NeedChange := FSelectionCount > 1;
        InternalClearSelection;
        InternalAddToSelection(HitInfo.HitNode, True);
        if NeedChange then
        begin
          Invalidate;
          Change(nil);
        end;
      end
      else
        ClearSelection;
    end;

    // pending node edit
    if Focused and
      ((hiOnItemLabel in HitInfo.HitPositions) or ((toGridExtensions in FOptions.FMiscOptions) and
      (hiOnItem in HitInfo.HitPositions))) and NodeSelected and not NewColumn and ShiftEmpty then
      Include(FStates, tsEditPending);

    // focus change
    if not Focused and CanFocus then
      SetFocus;

    // User starts a selection with a selection rectangle.
    if not (toDisableDrawSelection in FOptions.FSelectionOptions) and not IsHit and MultiSelect then
    begin
      Include(FStates, tsDrawSelPending);
      FDrawSelShiftState := ShiftState;
      FNewSelRect := Rect(Message.XPos - FOffsetX, Message.YPos - FOffsetY, Message.XPos - FOffsetX,
        Message.YPos - FOffsetY);
      FLastSelRect := FNewSelRect;
      if not IsCellHit then
        Exit;
    end;

    // Keep current mouse position.
    FLastClickPos := Point(Message.XPos, Message.YPos);

    // Handle selection and node focus change.
    if (IsHit or IsCellHit) and
       DoFocusChanging(FFocusedNode, HitInfo.HitNode, FFocusedColumn, Column) then
    begin
      if NewColumn then
      begin
        InvalidateColumn(FFocusedColumn);
        InvalidateColumn(Column);
        FFocusedColumn := Column;
      end;
      if DragKind = dkDock then
      begin
        StopTimer(ScrollTimer);
        FStates := FStates - [tsScrollPending, tsScrolling];
      end;
      // Get the currently focused node to make multiple multi-selection blocks possible.
      LastFocused := FFocusedNode;
      DoFocusNode(HitInfo.HitNode, False);

      if MultiSelect and not Dragging and not ShiftEmpty then
        HandleClickSelection(LastFocused, HitInfo.HitNode, ShiftState)
      else
      begin
        if ShiftEmpty then
          FRangeAnchor := HitInfo.HitNode;

        // If the hit node is not yet selected then do it now.
        if not NodeSelected then
          AddToSelection(HitInfo.HitNode);
      end;

      DoFocusChange(FFocusedNode, FFocusedColumn);

      // drag'n drop initiation
      if AutoDrag then
        BeginDrag(False);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.HandleMouseUp(var Message: TWMMouse; const HitInfo: THitInfo);

// Counterpart to the mouse down handler.

var
  ReselectFocusedNode: Boolean;

begin
  if not (tsVCLDragPending in FStates) then
  begin
    // reset pending or persistent states
    if IsMouseSelecting then
    begin
      FStates := FStates - [tsDrawSelecting, tsDrawSelPending];
      Invalidate;
    end;

    if tsClearPending in FStates then
    begin
      ReselectFocusedNode := Assigned(FFocusedNode) and (vsSelected in FFocusedNode.States);
      ClearSelection;
      if ReselectFocusedNode then
        AddToSelection(FFocusedNode);
    end;

    FStates := FStates - [tsOLEDragPending, tsOLEDragging, tsClearPending, tsDrawSelPending, tsScrollPending, tsScrolling];
    StopTimer(ScrollTimer);

    // An asssigned check node shows a pending check event.
    if Assigned(FCheckNode) then
    begin
      // Is the mouse still over the same node?
      if (HitInfo.HitNode = FCheckNode) and (hiOnItem in HitInfo.HitPositions) then
      begin
        ChangeCheckState(FCheckNode, FPendingCheckState);
        DoCheckClick(FCheckNode, FPendingCheckState);
      end
      else
        FCheckNode.CheckState := UnpressedState[FCheckNode.CheckState];
      InvalidateNode(FCheckNode);
      FCheckNode := nil;
    end;

    if (FHeader.FColumns.FClickIndex > NoColumn) and (FHeader.FColumns.FClickIndex = HitInfo.HitColumn) then
      DoColumnClick(HitInfo.HitColumn, KeysToShiftState(Message.Keys));

    // handle a pending edit event
    if tsEditPending in FStates then
    begin
      // Is the mouse still over the same node?
      if (HitInfo.HitNode = FFocusedNode) and (hiOnItem in HitInfo.HitPositions) and
         CanEdit(FFocusedNode, HitInfo.HitColumn) then
      begin
        FEditColumn := FFocusedColumn;
        SetTimer(Handle, EditTimer, FEditDelay, nil);
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.HasPopupMenu(Node: PVirtualNode; Column: Integer; Pos: TPoint): Boolean;

// Determines whether the tree got a popup menu, either in its PopupMenu property, via the OnGetPopupMenu event or
// through inheritannce. The latter case must be checked by the descentant which must override this method.
 
begin
  Result := Assigned(PopupMenu) or Assigned(DoGetPopupMenu(Node, Column, Pos));
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.InitChildren(Node: PVirtualNode);

// Initiates the initialization of the child number of the given node.

var
  Count: Cardinal;

begin
  if Assigned(Node) and (Node <> FRoot) and (vsHasChildren in Node.States) then
  begin
    Count := Node.ChildCount; 
    DoInitChildren(Node, Count);
    if Count = 0 then
    begin
      // Remove any child node which is already there.
      DeleteChildren(Node);
      Exclude(Node.States, vsHasChildren);
    end
    else
      SetChildCount(Node, Count);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.InitNode(Node: PVirtualNode);

// Initiates the initialization of the given node to allow the application to load needed data for it.

var
  InitStates: TVirtualNodeInitStates;

begin
  with Node^ do
  begin
    InitStates := [];
    if Parent = FRoot then
      DoInitNode(nil, Node, InitStates)
    else
      DoInitNode(Parent, Node, InitStates);
    Include(States, vsInitialized);
    if ivsDisabled in InitStates then
      Include(States, vsDisabled);
    if ivsHasChildren in InitStates then
      Include(States, vsHasChildren);
    if ivsSelected in InitStates then
    begin
      FSingletonNodeArray[0] := Node;
      InternalAddToSelection(FSingletonNodeArray, 1, False);
    end;

    // Expanded may already be set (when called from ReinitNode) or be set in DoInitNode, allow both.
    if (vsExpanded in Node.States) xor (ivsExpanded in InitStates) then
    begin
      // Expand node if not yet done (this will automatically initialize child nodes).
      if ivsExpanded in InitStates then
        ToggleNode(Node)
      else
        // If the node already was expanded then explicitly trigger child initialization.
        if vsHasChildren in Node.States then
          InitChildren(Node);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.InternalAddFromStream(Stream: TStream; Version: Integer; Node: PVirtualNode);

// Loads nodes from the given stream and adds them as children to Node.
// Because the new nodes might be selected this method also fixes the selection array.

var
  Stop: PVirtualNode;
  LastVisibleCount: Cardinal;
  Index: Integer;

begin
  if Node = nil then
    Node := FRoot;

  // Read in the new nodes, keep number of visible nodes for a correction.
  LastVisibleCount := FVisibleCount;
  ReadNode(Stream, Version, Node);

  // I need to fix the visible count here because of the hierarchical load procedure.
  if (Node = FRoot) or ([vsExpanded, vsVisible] * Node.Parent.States = [vsExpanded, vsVisible]) then
    FVisibleCount := LastVisibleCount + CountVisibleChildren(Node)
  else
    FVisibleCount := LastVisibleCount;

  // Fix selection array.
  ClearTempCache;
  if Node = FRoot then
    Stop := nil
  else
    Stop := Node.NextSibling;

  if toMultiSelect in FOptions.FSelectionOptions then
  begin
    // Add all nodes which were selected before to the current selection (unless they are already there).
    while Node <> Stop do
    begin
      if (vsSelected in Node.States) and not FindNodeInSelection(Node, Index, 0, High(FSelection)) then
        InternalCacheNode(Node);
      Node := GetNextNoInit(Node);
    end;
    if FTempNodeCount > 0 then
      AddToSelection(FTempNodeCache, FTempNodeCount, True);
    ClearTempCache;
  end
  else // No further selected nodes allowed so delete the corresponding flag in all new nodes.
    while Node <> Stop do
    begin
      Exclude(Node.States, vsSelected);
      Node := GetNextNoInit(Node);
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.InternalAddToSelection(Node: PVirtualNode; ForceInsert: Boolean): Boolean;

begin
  Assert(Assigned(Node), 'Node must not be nil!');
  FSingletonNodeArray[0] := Node;
  Result := InternalAddToSelection(FSingletonNodeArray, 1, ForceInsert);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.InternalAddToSelection(const NewItems: TNodeArray; NewLength: Integer;
  ForceInsert: Boolean): Boolean;

// Internal version of method AddToSelection which does not trigger OnChange events

var
  I, J: Integer;
  CurrentEnd: Integer;
  Constrained,
  SiblingConstrained: Boolean;

begin
  // The idea behind this code is to use a kind of reverse merge sort. QuickSort is quite fast
  // and would do the job here too but has a serious problem with already sorted lists like FSelection.

  // 1) Remove already selected items, mark all other as being selected.
  if ForceInsert then
  begin
    for I := 0 to NewLength - 1 do
      Include(NewItems[I].States, vsSelected);
  end
  else
  begin
    Constrained := toLevelSelectConstraint in FOptions.FSelectionOptions;
    if Constrained and (FLastSelectionLevel = -1) then
      FLastSelectionLevel := GetNodeLevel(NewItems[0]);
    SiblingConstrained := toSiblingSelectConstraint in FOptions.FSelectionOptions;
    if SiblingConstrained and (FRangeAnchor = nil) then
      FRangeAnchor := NewItems[0];

    for I := 0 to NewLength - 1 do
      if ([vsSelected, vsDisabled] * NewItems[I].States <> []) or
         (Constrained and (Cardinal(FLastSelectionLevel) <> GetNodeLevel(NewItems[I]))) or
         (SiblingConstrained and (FRangeAnchor.Parent <> NewItems[I].Parent))or
         (not CanSelect(NewItems[I]){ and (FRangeAnchor<>NewItems[I])}) then
        Inc(Cardinal(NewItems[I]))
      else
        Include(NewItems[I].States, vsSelected);
  end;


  I := PackArray(NewItems, NewLength);
  if I > -1 then
    NewLength := I;

  Result := NewLength > 0;
  if Result then
  begin
    // 2) Sort the new item list so we can easily traverse it.
    if NewLength > 1 then
      QuickSort(NewItems, 0, NewLength - 1);
    // 3) Make room in FSelection for the new items.
    if FSelectionCount + NewLength >= Length(FSelection) then
      SetLength(FSelection, FSelectionCount + NewLength);

    // 4) Merge in new items
    J := NewLength - 1;
    CurrentEnd := FSelectionCount - 1;

    while J >= 0 do
    begin
      // First insert all new entries which are greater than the greatest entry in the old list.
      // If the current end marker is < 0 then there's nothing more to move in the selection
      // array and only the remaining new items must be inserted.
      if CurrentEnd >= 0 then
      begin
        while (J >= 0) and (Cardinal(NewItems[J]) > Cardinal(FSelection[CurrentEnd])) do
        begin
          FSelection[CurrentEnd + J + 1] := NewItems[J];
          Dec(J);
        end;
        // early out if nothing more needs to be copied
        if J < 0 then
          Break;
      end
      else
      begin
        // insert remaining new entries at position 0
        Move(NewItems[0], FSelection[0], (J + 1) * SizeOf(Pointer));
        // nothing more to do so exit main loop
        Break;
      end;

      // find the last entry in the remaining selection list which is smaller then the largest
      // entry in the remaining new items list
      FindNodeInSelection(NewItems[J], I, 0, CurrentEnd);
      Dec(I);
      // move all entries which are greater than the greatest entry in the new items list up
      // so the remaining gap travels down to where new items must be inserted
      Move(FSelection[I + 1], FSelection[I + J + 2], (CurrentEnd - I) * SizeOf(Pointer));
      CurrentEnd := I;
    end;

    Inc(FSelectionCount, NewLength);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.InternalCacheNode(Node: PVirtualNode);

// Adds the given node to the temporary node cache (used when collecting possibly large amounts of nodes).

var
  Len: Cardinal;

begin
  Len := Length(FTempNodeCache);
  if FTempNodeCount = Len then
  begin
    if Len < 100 then
      Len := 100
    else
      Len := Len + Len div 10;
    SetLength(FTempNodeCache, Len);
  end;
  FTempNodeCache[FTempNodeCount] := Node;
  Inc(FTempNodeCount);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.InternalClearSelection;

var
  Count: Integer;

begin
  // It is possible that there are invalid node references in the selection array
  // if the tree update is locked and changes in the structure were made.
  // Handle this potentially dangerous situation by packing the selection array explicitely.
  if FUpdateCount > 0 then
  begin
    Count := PackArray(FSelection, FSelectionCount);
    if Count > -1 then
    begin
      FSelectionCount := Count;
      SetLength(FSelection, FSelectionCount);
    end;
  end;

  while FSelectionCount > 0 do
  begin
    Dec(FSelectionCount);
    Exclude(FSelection[FSelectionCount].States, vsSelected);
  end;
  ResetRangeAnchor;
  FSelection := nil;
  Exclude(FStates, tsClearPending);
end;                                         

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.InternalData(Node: PVirtualNode): Pointer;

begin
  Result := nil;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.InternalRemoveFromSelection(Node: PVirtualNode);

// Special version to mark a node to be no longer in the current selection. PackArray must
// be used to remove finally those entries.

var
  Index: Integer;

begin
  // Because pointers are always DWORD aligned we can simply increment all those
  // which we want to have removed (see also PackArray) and still have the
  // order in the list preserved.
  if FindNodeInSelection(Node, Index, -1, -1) then
  begin
    Exclude(Node.States, vsSelected);
    Inc(Cardinal(FSelection[Index]));
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.InvalidateCache;

// Marks the cache as invalid.

begin
  FStates := FStates + [tsValidationNeeded] - [tsUseCache];
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.MarkCutCopyNodes;

// Sets the vsCutOrCopy style in every currently selected but not disabled node to indicate it is
// now part of a clipboard operation.

var
  Nodes: TNodeArray;
  I: Integer;

begin
  Nodes := nil;
  if FSelectionCount > 0 then
  begin
    // need the current selection sorted to exclude selected nodes which are children, grandchildren etc. of
    // already selected nodes 
    Nodes := GetSortedSelection(False);
    for I := 0 to High(Nodes) do
      with Nodes[I]^ do
        if not (vsDisabled in States) then
          Include(States, vsCutOrCopy);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.Loaded;

var
  LastRootCount: Cardinal;

begin
  // If a root node count has been set during load of the tree then update its child structure now
  // as this hasn't been done yet in this case.
  if (tsNeedRootCountUpdate in FStates) and (FRoot.ChildCount > 0) then
  begin
    Exclude(FStates, tsNeedRootCountUpdate);
    LastRootCount := FRoot.ChildCount;
    FRoot.ChildCount := 0;
    BeginUpdate;
    SetChildCount(FRoot, LastRootCount);
    EndUpdate;
  end;
  FHeader.RecalculateHeader;
  if hoAutoResize in FHeader.FOptions then
    FHeader.FColumns.AdjustAutoSize(InvalidColumn, True);

  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.MainColumnChanged;

begin
  DoCancelEdit;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.MouseMove(Shift: TShiftState; X, Y: Integer);

var
  R: TRect;
  
begin
  // Remove current selection in case the user clicked somewhere in the window (but not a node)
  // and moved the mouse.
  if tsDrawSelPending in FStates then
  begin
    if CalculateSelectionRect(X, Y) then
    begin
      InvalidateRect(Handle, @FNewSelRect, False);
      UpdateWindow(Handle);
      if (Abs(FNewSelRect.Right - FNewSelRect.Left) > Mouse.DragThreshold) or
         (Abs(FNewSelRect.Bottom - FNewSelRect.Top) > Mouse.DragThreshold) then
      begin
        if tsClearPending in FStates then
        begin
          Exclude(FStates, tsClearPending);
          ClearSelection;
        end;
        FStates := FStates - [tsDrawSelPending] + [tsDrawSelecting];
        // reset to main column for multiselection
        FocusedColumn := FHeader.MainColumn;

        // The current rectangle may already include some node captions. Handle this.
        if HandleDrawSelection(X, Y) then
          InvalidateRect(Handle, nil, False);
      end;
    end;
  end
  else
  begin
    // If both wheel panning and auto scrolling are pending then the user moved the mouse while holding down the
    // middle mouse button. This means panning is being used, hence remove the autoscroll flag.
    if [tsWheelPanning, tsWheelScrolling] * FStates = [tsWheelPanning, tsWheelScrolling] then
    begin
      if ((Abs(FLastClickPos.X - X) >= Mouse.DragThreshold) or (Abs(FLastClickPos.Y - Y) >= Mouse.DragThreshold)) then
        Exclude(FStates, tsWheelScrolling);
    end;

    // Really start dragging if the mouse has been moved more than the threshold.
    if (tsOLEDragPending in FStates) and ((Abs(FLastClickPos.X - X) >= FDragThreshold) or
       (Abs(FLastClickPos.Y - Y) >= FDragThreshold)) then
      DoDragging(FLastClickPos)
    else
    begin 
      if CanAutoScroll then
        DoAutoScroll(X, Y);
      if [tsWheelPanning, tsWheelScrolling] * FStates <> [] then
        AdjustPanningCursor(X, Y);
      if not IsMouseSelecting then
      begin
        HandleHotTrack(X, Y);
        inherited MouseMove(Shift, X, Y);
      end
      else
      begin
        // Handle draw selection if required, but don't do the work twice if the
        // auto scrolling code already cares about the selection. 
        if not (tsScrolling in FStates) and CalculateSelectionRect(X, Y) then
        begin 
          // If something in the selection changed then invalidate the entire
          // tree instead trying to figure out the display rects of all changed nodes.
          if HandleDrawSelection(X, Y) then
            InvalidateRect(Handle, nil, False)
          else
          begin
            UnionRect(R, OrderRect(FNewSelRect), OrderRect(FLastSelRect));
            OffsetRect(R, FOffsetX, FOffsetY);
            InvalidateRect(Handle, @R, False);
          end;
          UpdateWindow(Handle);
        end;
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.Notification(AComponent: TComponent; Operation: TOperation);

begin
  if (AComponent <> Self) and (Operation = opRemove) then
  begin
    // Check for components linked to the tree.
    if AComponent = FImages then
    begin
      FImages := nil;
      if not (csDestroying in ComponentState) then
        Invalidate;
    end
    else
      if AComponent = FStateImages then
      begin
        FStateImages := nil;
        if not (csDestroying in ComponentState) then
          Invalidate;
      end
      else
        if AComponent = FCustomCheckImages then
        begin
          FCustomCheckImages := nil;
          FCheckImageKind := ckLightCheck;
          if not (csDestroying in ComponentState) then
            Invalidate;
        end
        else
          if AComponent = PopupMenu then
            PopupMenu := nil
          else
            // Check for components linked to the header.
            if AComponent = FHeader.FImages then
              FHeader.Images := nil
            else
              if AComponent = FHeader.PopupMenu then
                FHeader.PopupMenu := nil;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.Paint;

// Window paint routine. Used when the tree window needs to be updated.

var
  Window: TRect;
  Target: TPoint;

begin
  // Determine area of the entire tree to be displayed in the control.
  Window := Canvas.ClipRect;
  Target := Window.TopLeft;

  // The clipping rectangle is given in client coordinates of the window. We have to convert it into
  // a sliding window of the tree image.
  OffsetRect(Window, -FOffsetX, -FOffsetY);
  PaintTree(Canvas, Window, Target, [poBackground, poColumnColor, poDrawFocusRect, poDrawDropMark, poDrawSelection,
    poGridLines]);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.PaintSelectionRectangle(Target: TCanvas; WindowOrgX: Integer; const SelectionRect: TRect;
  TargetRect: TRect);

// Helper routine to draw a selection rectangle in the mode determined by DrawSelectionMode.

var
  BlendRect: TRect;
  TextColorBackup,
  BackColorBackup: COLORREF;   // used to restore forground and background colors when drawing a selection rectangle

begin
  if ((FDrawSelectionMode = smDottedRectangle) and not (tsUseThemes in FStates)) or
    not MMXAvailable then
  begin
    // Classical selection rectangle using dotted borderlines.
    TextColorBackup := GetTextColor(Target.Handle);
    SetTextColor(Target.Handle, $FFFFFF);
    BackColorBackup := GetBkColor(Target.Handle);
    SetBkColor(Target.Handle, 0);
    Target.DrawFocusRect(SelectionRect);
    SetTextColor(Target.Handle, TextColorBackup);
    SetBkColor(Target.Handle, BackColorBackup);
  end
  else
  begin
    // Modern alpha blended style.
    OffsetRect(TargetRect, WindowOrgX, 0);
    if IntersectRect(BlendRect, OrderRect(SelectionRect), TargetRect) then
    begin
      OffsetRect(BlendRect, -WindowOrgX, 0);
      AlphaBlend(0, Target.Handle, BlendRect, Point(0, 0), bmConstantAlphaAndColor, 64,
        ColorToRGB(FColors.SelectionRectangleBlendColor));

      Target.Brush.Color := FColors.SelectionRectangleBorderColor;
      Target.FrameRect(SelectionRect);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.PaintTree(TargetCanvas: TCanvas; Window: TRect; Target: TPoint;
  PaintOptions: TVTInternalPaintOptions);

// This is the core paint routine of the tree. It is responsible for maintaining the paint cycles per node as well
// as coordinating drawing of the various parts of the tree image.
// TargetCanvas is the canvas to which to draw the tree image. This is usually the tree window itself but could well
// be a bitmap or printer canvas.
// Window determines which part of the entire tree image to draw. The full size of the virtual image is determined
// by GetTreeRect.
// Target is the position in TargetCanvas where to draw the tree part specified by Window.
// PaintOptions determines what of the tree to draw. For different tasks usually different parts need to be drawn, with
// a full image in the window, selected only nodes for a drag image etc.

const
  ImageKind: array[Boolean] of TVTImageKind = (ikNormal, ikSelected);

var
  DrawSelectionRect,
  UseBackground,
  ShowImages,
  ShowStateImages,
  ShowCheckImages,
  UseColumns,
  IsMainColumn: Boolean;

  VAlign,
  IndentSize,
  ButtonX,
  ButtonY: Integer;
  Temp: PVirtualNode;
  LineImage: TLineImage;
  PaintInfo: TVTPaintInfo;     // all necessary information about a node to pass to the paint routines

  R,                           // the area of an entire node in its local coordinate
  TargetRect,                  // the area of a node (part) in the target canvas
  SelectionRect: TRect;        // ordered rectangle used for drawing the selection focus rect
  NextColumn: TColumnIndex;
  BaseOffset: Integer;         // top position of the top node to draw given in absolute tree coordinates
  NodeBitmap: TBitmap;         // small buffer to draw flicker free
  MaximumRight,                // maximum horizontal target position
  MaximumBottom: Integer;      // maximum vertical target position
  SelectLevel: Integer;        // > 0 if current node is selected or child/grandchild etc. of a selected node
  FirstColumn: TColumnIndex;   // index of first column which is at least partially visible in the given window

begin
  Include(FStates, tsPainting);

  DoBeforePaint(TargetCanvas);

  // Create small bitmaps and initialize default values.
  // The bitmaps are used to paint one node at a time and to draw the result to the target (e.g. screen) in one step,
  // to prevent flickering.
  NodeBitmap := TBitmap.Create;
  // For alpha blending we need the 32 bit pixel format.
  NodeBitmap.PixelFormat := pf32Bit;

  // Prepare paint info structure and lock the back bitmap canvas to avoid that it gets freed on the way.
  FillChar(PaintInfo, SizeOf(PaintInfo), 0);
  PaintInfo.Canvas := NodeBitmap.Canvas;
  NodeBitmap.Canvas.Lock;
  try
    // Prepare the current selection rectangle once. The corner points are absolute tree coordinates.
    SelectionRect := OrderRect(FNewSelRect);
    DrawSelectionRect := IsMouseSelecting and not IsRectEmpty(SelectionRect);

    // R represents an entire node (all columns), but is a bit unprecise when it comes to
    // trees without any column defined, because FRangeX only represents the maximum width of all
    // nodes in the client area (not all defined nodes). There might be, however, wider nodes somewhere. Without full
    // validation I cannot better determine the width, though. By using at least the control's width it is ensured
    // that the tree is fully displayed on screen.
    R := Rect(0, 0, Max(FRangeX, ClientWidth), 0);
    NodeBitmap.Width := Window.Right - Window.Left;

    // Make sure the buffer bitmap and target bitmap use the same transformation mode.
    SetMapMode(NodeBitmap.Canvas.Handle, GetMapMode(TargetCanvas.Handle));

    // For quick checks some intermediate variables are used.
    UseBackground := (toShowBackground in FOptions.FPaintOptions) and (FBackground.Graphic is TBitmap) and
      (poBackground in PaintOptions);
    ShowImages := Assigned(FImages);
    ShowStateImages := Assigned(FStateImages);
    ShowCheckImages := Assigned(FCheckImages) and (toCheckSupport in FOptions.FMiscOptions);
    UseColumns := FHeader.UseColumns;

    // Adjust paint options to tree settings.
    if not Focused and (toHideSelection in FOptions.FPaintOptions) then
      Exclude(PaintOptions, poDrawSelection);
    if toHideFocusRect in FOptions.FPaintOptions then
      Exclude(PaintOptions, poDrawFocusRect);
      
    // Determine node to start drawing with.
    BaseOffset := 0;
    PaintInfo.Node := GetNodeAt(0, Window.Top, False, BaseOffset);

    // Transform selection rectangle into node bitmap coordinates.
    if DrawSelectionRect then
      OffsetRect(SelectionRect, 0, -BaseOffset);

    // The target rectangle holds the coordinates of the exact area to blit in target canvas coordinates.
    // It is usually smaller than an entire node and wanders while the paint loop advances.
    MaximumRight := Target.X + (Window.Right - Window.Left);
    MaximumBottom := Target.Y + (Window.Bottom - Window.Top);

    TargetRect := Rect(Target.X, Target.Y - (Window.Top - BaseOffset), MaximumRight, 0);
    TargetRect.Bottom := TargetRect.Top;

    // This marker gets the index of the first column which is visible in the given window.
    // This is needed for column based background colors.
    FirstColumn := InvalidColumn;
    
    if Assigned(PaintInfo.Node) then
    begin
      SelectLevel := InitializeLineImageAndSelectLevel(PaintInfo.Node, LineImage);
      IndentSize := Length(LineImage);

      // Precalculate horizontal position of buttons relative to the column start.
      ButtonX := (Length(LineImage) * Integer(FIndent)) + Trunc((Integer(FIndent) - FPlusBM.Width) / 2 + 0.5) - FIndent;

      // ----- main node paint loop
      while Assigned(PaintInfo.Node) do
      begin
        // Initialize node if not already done.
        if not (vsInitialized in PaintInfo.Node.States) then
          InitNode(PaintInfo.Node);
        if vsSelected in PaintInfo.Node.States then
          Inc(SelectLevel);

        // Adjust the brush origin for dotted lines depending on the current source position.
        // This value is used in DrawDottedHLine and DrawDottedVLine where the dotted lines actually drawn.
        PaintInfo.BrushOrigin := Point(Window.Left and 1, BaseOffset and 1);
        TargetRect.Bottom := TargetRect.Top + PaintInfo.Node.NodeHeight;

        // If poSelectedOnly is active then do the following stuff only for selected nodes or nodes
        // which are children of selected nodes.
        if (SelectLevel > 0) or not (poSelectedOnly in PaintOptions) then
        begin
          // Adjust height of temporary node bitmap.
          with NodeBitmap do
          begin
            if Height <> PaintInfo.Node.NodeHeight then
            begin
              // Avoid that the VCL copies the bitmap while changing its height.
              Height := 0;
              Height := PaintInfo.Node.NodeHeight;
              SetWindowOrgEx(Canvas.Handle, Window.Left, 0, nil);
              R.Bottom := PaintInfo.Node.NodeHeight;
            end;
          end;                            
          CalculateVerticalAlignments(ShowImages, ShowStateImages, PaintInfo.Node, VAlign, ButtonY);

          // Let application decide whether the node should normally be drawn or by the application itself.
          if not DoBeforeItemPaint(PaintInfo.Canvas, PaintInfo.Node, R) then
          begin
            // The node background can contain a single color, a bitmap or can be drawn by the application.
            ClearNodeBackground(PaintInfo.Canvas, PaintInfo.Node, UseBackground, True,
              Rect(Window.Left, TargetRect.Top, Window.Right, TargetRect.Bottom));
                                                                                                            
            // Prepare column, position and node clipping rectangle.
            PaintInfo.CellRect := R;
            if UseColumns then
              InitializeFirstColumnValues(PaintInfo);

            // Now go through all visible columns (there's still one run if columns aren't used).
            with FHeader.FColumns do
            begin
              while ((PaintInfo.Column > InvalidColumn) or not UseColumns)
                and (PaintInfo.CellRect.Left < Window.Right) do
              begin
                if UseColumns then
                begin
                  PaintInfo.Column := FPositionToIndex[PaintInfo.Position];
                  if FirstColumn = InvalidColumn then
                    FirstColumn := PaintInfo.Column;
                  PaintInfo.BidiMode := Items[PaintInfo.Column].FBiDiMode;
                  PaintInfo.Alignment := Items[PaintInfo.Column].FAlignment;
                end
                else
                begin
                  PaintInfo.Column := NoColumn;
                  PaintInfo.BidiMode := BidiMode;
                  PaintInfo.Alignment := FAlignment;
                end;

                PaintInfo.PaintOptions := PaintOptions;
                with PaintInfo do
                begin
                  if (tsEditing in FStates) and (Node = FFocusedNode) and
                    ((Column = FEditColumn) or not UseColumns) then
                    Exclude(PaintOptions, poDrawSelection);
                  if not UseColumns or
                    ((vsSelected in Node.States) and (toFullRowSelect in FOptions.FSelectionOptions)) or
                    (coParentColor in Items[PaintInfo.Column].Options) then
                    Exclude(PaintOptions, poColumnColor);
                end;
                IsMainColumn := PaintInfo.Column = FHeader.MainColumn;

                // Consider bidi mode here. In RTL context means left alignment actually right alignment and vice versa.
                if PaintInfo.BidiMode <> bdLeftToRight then
                  ChangeBiDiModeAlignment(PaintInfo.Alignment);

                // Paint the current cell if it is marked as being visible or columns aren't used and
                // if this cell belongs to the main column if only the main column should be drawn.
                if (not UseColumns or (coVisible in Items[PaintInfo.Column].FOptions)) and
                  (not (poMainOnly in PaintOptions) or IsMainColumn) then
                begin
                  AdjustPaintCellRect(PaintInfo, NextColumn);

                  // Paint the cell only if it is in the current window.
                  if PaintInfo.CellRect.Right > Window.Left then
                  begin
                    with PaintInfo do
                    begin
                      // Fill in remaining values in the paint info structure.
                      NodeWidth := DoGetNodeWidth(Node, Column, Canvas);
                      // Not the entire cell is covered by text. Hence we need a running rectangle to follow up.
                      ContentRect := CellRect;
                      // Set up the distance from column border (margin).
                      if BidiMode <> bdLeftToRight then
                        Dec(ContentRect.Right, FMargin)
                      else
                        Inc(ContentRect.Left, FMargin);

                      if ShowCheckImages and IsMainColumn then
                      begin
                        ImageInfo[iiCheck].Index := GetCheckImage(Node);
                        if ImageInfo[iiCheck].Index > -1 then
                        begin
                          AdjustImageBorder(FCheckImages, BidiMode, VAlign, ContentRect, ImageInfo[iiCheck]);
                          ImageInfo[iiCheck].Ghosted := False;
                        end;
                      end
                      else
                        ImageInfo[iiCheck].Index := -1;
                      if ShowStateImages then
                      begin
                        ImageInfo[iiState].Index := GetImageIndex(Node, ikState, Column, ImageInfo[iiState].Ghosted);
                        if ImageInfo[iiState].Index > -1 then
                          AdjustImageBorder(FStateImages, BidiMode, VAlign, ContentRect, ImageInfo[iiState]);
                      end
                      else
                        ImageInfo[iiState].Index := -1;
                      if ShowImages then
                      begin
                        ImageInfo[iiNormal].Index := GetImageIndex(Node, ImageKind[vsSelected in Node.States], Column,
                          ImageInfo[iiNormal].Ghosted);
                        if ImageInfo[iiNormal].Index > -1 then
                          AdjustImageBorder(FImages, BidiMode, VAlign, ContentRect, ImageInfo[iiNormal]);
                      end
                      else
                        ImageInfo[iiNormal].Index := -1;

                      // Take the space for the tree lines into account.
                      if IsMainColumn then
                        AdjustCoordinatesByIndent(PaintInfo, IndentSize);

                      if UseColumns then
                        LimitPaintingToArea(Canvas, CellRect);

                      // Paint the horizontal grid line.
                      if (poGridLines in PaintOptions) and (toShowHorzGridLines in FOptions.FPaintOptions) then
                      begin
                        Canvas.Font.Color := FColors.GridLineColor;
                        if IsMainColumn and (FLineMode = lmBands) then
                        begin
                          if BidiMode = bdLeftToRight then
                          begin
                            DrawDottedHLine(PaintInfo, CellRect.Left + IndentSize * Integer(FIndent), CellRect.Right - 1,
                              CellRect.Bottom - 1);
                          end
                          else
                          begin
                            DrawDottedHLine(PaintInfo, CellRect.Left, CellRect.Right - IndentSize * Integer(FIndent) - 1,
                              CellRect.Bottom - 1);
                          end;
                        end
                        else
                          DrawDottedHLine(PaintInfo, CellRect.Left, CellRect.Right, CellRect.Bottom - 1);
                        Dec(CellRect.Bottom);
                        Dec(ContentRect.Bottom);
                      end;

                      if UseColumns then
                      begin
                        // Paint vertical grid line.
                        // Don't draw if this is the last column and the header is in autosize mode.
                        if (poGridLines in PaintOptions) and (toShowVertGridLines in FOptions.FPaintOptions) and
                          (not (hoAutoResize in FHeader.FOptions) or (Position < TColumnPosition(Count - 1))) then
                        begin
                          if (BidiMode = bdLeftToRight) or not ColumnIsEmpty(Node, Column) then
                          begin
                            Canvas.Font.Color := FColors.GridLineColor;
                            DrawDottedVLine(PaintInfo, CellRect.Top, CellRect.Bottom, CellRect.Right - 1);
                          end;
                          Dec(CellRect.Right);
                          Dec(ContentRect.Right);
                        end;
                      end;

                      // Prepare background and focus rect for the current cell.
                      PrepareCell(PaintInfo);

                      // Some parts are only drawn for the main column.
                      if IsMainColumn then
                      begin
                        if toShowTreeLines in FOptions.FPaintOptions then
                          PaintTreeLines(PaintInfo, VAlign, IndentSize, LineImage);
                        // Show node button if allowed, if there child nodes and at least one of the child
                        // nodes is visible or auto button hiding is disabled. 
                        if (toShowButtons in FOptions.FPaintOptions) and (vsHasChildren in Node.States) and
                          not ((vsAllChildrenHidden in Node.States) and
                          (toAutoHideButtons in TreeOptions.FAutoOptions)) then
                          PaintNodeButton(Canvas, Node, CellRect, ButtonX, ButtonY, BidiMode);

                        if ImageInfo[iiCheck].Index > -1 then
                          PaintCheckImage(PaintInfo);
                      end;

                      if ImageInfo[iiState].Index > -1 then
                        PaintImage(PaintInfo, iiState, FStateImages, False);
                      if ImageInfo[iiNormal].Index > -1 then
                        PaintImage(PaintInfo, iiNormal, FImages, True);

                      // Now let descendants or applications draw whatever they want,
                      // but don't draw the node if it is currently being edited.
                      if not ((tsEditing in FStates) and (Node = FFocusedNode) and
                        ((Column = FEditColumn) or not UseColumns)) then
                        DoPaintNode(PaintInfo);

                      DoAfterCellPaint(Canvas, Node, Column, CellRect);
                    end;
                  end;

                  // leave after first run if columns aren't used
                  if not UseColumns then
                    Break;
                end
                else
                  NextColumn := GetNextVisibleColumn(PaintInfo.Column);

                SelectClipRgn(PaintInfo.Canvas.Handle, 0);
                // Stop column loop if there are no further columns in the given window.
                if (PaintInfo.CellRect.Left >= Window.Right) or (NextColumn = InvalidColumn) then
                  Break;

                // Move on to next column which might not be the one immediately following the current one
                // because of auto span feature.
                PaintInfo.Position := Items[NextColumn].Position;

                // Move clip rectangle and continue.
                if coVisible in Items[NextColumn].FOptions then
                  with PaintInfo do
                  begin
                    Items[NextColumn].GetAbsoluteBounds(CellRect.Left, CellRect.Right);
                    CellRect.Bottom := Node.NodeHeight;
                    ContentRect.Bottom := Node.NodeHeight;
                  end;
              end;
            end;
        
            // This node is finished, notify descentants/application.
            with PaintInfo do
            begin
              DoAfterItemPaint(Canvas, Node, R);

              // Final touch for this node: mark it if it is the current drop target node.
              if (Node = FDropTargetNode) and (toShowDropmark in FOptions.FPaintOptions) and
                (poDrawDropMark in PaintOptions) then
                DoPaintDropMark(Canvas, Node, R);
            end;
          end;

          with PaintInfo.Canvas do
          begin
            if DrawSelectionRect then
            begin
              PaintSelectionRectangle(PaintInfo.Canvas, Window.Left, SelectionRect, Rect(0, 0, NodeBitmap.Width,
                NodeBitmap.Height));
            end;

            // Put the constructed node image onto the target canvas.
            with TargetRect, NodeBitmap do
              BitBlt(TargetCanvas.Handle, Left, Top, Width, Height, Canvas.Handle, Window.Left, 0, SRCCOPY);
          end;                                                                       
        end;

        Inc(TargetRect.Top, PaintInfo.Node.NodeHeight);
        if TargetRect.Top >= MaximumBottom then
          Break;

        // Keep selection rectangle coordinates in sync.
        if DrawSelectionRect then
          OffsetRect(SelectionRect, 0, -PaintInfo.Node.NodeHeight);

        // Advance to next visible node.
        Temp := GetNextVisible(PaintInfo.Node);
        if Assigned(Temp) then
        begin
          // Adjust line bitmap (and so also indentation level).
          if Temp.Parent = PaintInfo.Node then
          begin
            // New node is a child node. Need to adjust previous bitmap level.
            if IndentSize > 0 then
              if HasVisibleNextSibling(PaintInfo.Node) then
                LineImage[IndentSize - 1] := ltTopDown
              else
                LineImage[IndentSize - 1] := ltNone;
            // Enhance line type array if necessary.
            Inc(IndentSize);
            if Length(LineImage) <= IndentSize then
              SetLength(LineImage, IndentSize + 8);
            Inc(ButtonX, FIndent);
          end
          else
          begin
            // New node is at the same or higher tree level.
            // Take back select level increase if the node was selected
            if vsSelected in PaintInfo.Node.States then
              Dec(SelectLevel);
            if PaintInfo.Node.Parent <> Temp.Parent then
            begin
              // We went up one or more levels. Determine how many levels it was actually.
              while PaintInfo.Node.Parent <> Temp.Parent do
              begin
                Dec(IndentSize);
                Dec(ButtonX, FIndent);
                PaintInfo.Node := PaintInfo.Node.Parent;
                // Take back one selection level increase for every step up.
                if vsSelected in PaintInfo.Node.States then
                  Dec(SelectLevel);
              end;
            end;
          end;

          // Set new image in front of the new node.
          if IndentSize > 0 then
            if HasVisibleNextSibling(Temp) then
              LineImage[IndentSize - 1] := ltTopDownRight
            else
              LineImage[IndentSize - 1] := ltTopRight;
        end;

        PaintInfo.Node := Temp;
        if Assigned(Temp) then
          Inc(BaseOffset, Temp.NodeHeight)
        else
          Break;
      end;
    end;

    // Erase rest of window not covered by a node.
    if TargetRect.Top < MaximumBottom then
    begin
      // Keep the horizontal target position to determine the selection rectangle offset later (if necessary).
      BaseOffset := Target.X;
      Target := TargetRect.TopLeft;
      R := Rect(TargetRect.Left, 0, MaximumRight, MaximumBottom - Target.Y);
      TargetRect := Rect(0, 0, MaximumRight - Target.X, MaximumBottom - Target.Y);
      // Avoid unnecessary copying of bitmap content. This will destroy the DC handle too.
      NodeBitmap.Height := 0;
      NodeBitmap.PixelFormat := pf32Bit;
      NodeBitmap.Width := TargetRect.Right - TargetRect.Left + 1;
      NodeBitmap.Height := TargetRect.Bottom - TargetRect.Top + 1;

      // Call back application/descentants whether they want to erase this area.
      if not DoPaintBackground(NodeBitmap.Canvas, TargetRect) then
      begin
        if UseBackground then
        begin
          TileBackground(FBackground.Bitmap, NodeBitmap.Canvas, Target, TargetRect);
        end
        else
        begin
          // Consider here also colors of the columns.
          if UseColumns then
          begin
            SetWindowOrgEx(NodeBitmap.Canvas.Handle, Target.X, 0, nil);
            with FHeader.FColumns do
            begin
              // If there is no content in the tree then the first column has not yet been determined.
              if FirstColumn = InvalidColumn then
              begin
                FirstColumn := GetFirstVisibleColumn;
                repeat
                  if FirstColumn <> InvalidColumn then
                  begin
                    R.Left := Items[FirstColumn].Left;
                    R.Right := R.Left +  Items[FirstColumn].FWidth;
                    if R.Right > TargetRect.Left then
                      Break;
                    FirstColumn := GetNextVisibleColumn(FirstColumn);
                  end;
                until FirstColumn = InvalidColumn;
              end
              else
              begin
                R.Left := Items[FirstColumn].Left;
                R.Right := R.Left +  Items[FirstColumn].FWidth;
              end;

              while (FirstColumn <> InvalidColumn) and (R.Left < TargetRect.Right + Target.X) do
              begin
                if not (coParentColor in Items[FirstColumn].FOptions) then
                  NodeBitmap.Canvas.Brush.Color := Items[FirstColumn].FColor
                else
                  NodeBitmap.Canvas.Brush.Color := Color;

                NodeBitmap.Canvas.FillRect(R);
                FirstColumn := GetNextVisibleColumn(FirstColumn);
                if FirstColumn <> InvalidColumn then
                begin
                  R.Left := Items[FirstColumn].Left;
                  R.Right := R.Left + Items[FirstColumn].FWidth;
                end;
              end;
              // Erase also the part of the tree not covert by a column.
              if R.Right < TargetRect.Right + Target.X then
              begin
                R.Left := R.Right;
                R.Right := TargetRect.Right + Target.X;
                NodeBitmap.Canvas.Brush.Color := Color;
                NodeBitmap.Canvas.FillRect(R);
              end;
            end;
            SetWindowOrgEx(NodeBitmap.Canvas.Handle, 0, 0, nil);
          end
          else
          begin
            // No columns nor bitmap background. Simply erase it with the tree color.
            NodeBitmap.Canvas.Brush.Color := Color;
            NodeBitmap.Canvas.FillRect(TargetRect);
          end;
        end;
      end;

      if DrawSelectionRect then
      begin
        R := OrderRect(FNewSelRect);
        // Remap the selection rectangle to the current window of the tree.
        // Since Target has been used for other tasks BaseOffset got the left extent of the target position here.
        OffsetRect(R, -Target.X + BaseOffset - Window.Left, -Target.Y);
        SetBrushOrgEx(NodeBitmap.Canvas.Handle, 0, Target.X and 1, nil);
        PaintSelectionRectangle(NodeBitmap.Canvas, 0, R, TargetRect);
      end;
      with Target, NodeBitmap do
        BitBlt(TargetCanvas.Handle, X, Y, Width, Height, Canvas.Handle, 0, 0, SRCCOPY);
    end;
  finally
    NodeBitmap.Canvas.Unlock;
    NodeBitmap.Free;
  end;
  DoAfterPaint(TargetCanvas);
  Exclude(FStates, tsPainting);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.PanningWindowProc(var Message: TMessage);

var
  PS: TPaintStruct;
  Canvas: TCanvas;

begin
  if Message.Msg = WM_PAINT then
  begin
    BeginPaint(FPanningWindow, PS);
    Canvas := TCanvas.Create;
    Canvas.Handle := PS.hdc;
    try
      Canvas.Draw(0, 0, FPanningImage);
    finally
      Canvas.Handle := 0;
      Canvas.Free;
      EndPaint(FPanningWindow, PS);
    end;
    Message.Result := 0;
  end
  else
    with Message do
      Result := DefWindowProc(FPanningWindow, Msg, wParam, lParam);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.ReadChunk(Stream: TStream; Version: Integer; Node: PVirtualNode; ChunkType,
  ChunkSize: Integer): Boolean;

// Called while loading a tree structure, Node is already valid (allocated) at this point.
// The function handles the base and user chunks, any other chunk is marked as being unknown (result becomes False)
// and skipped. Descentants may handle them by overriding this method.
// Returns True if the chunk could be handled, otherwise False.

var
  ChunkBody: TBaseChunkBody;
  Run: PVirtualNode;
  LastPosition: Integer;

begin
  case ChunkType of
    BaseChunk:
      begin
        // Load base chunk's body (chunk header has already been consumed).
        if Version > 1 then
          Stream.Read(ChunkBody, SizeOf(ChunkBody))
        else
        begin
          with ChunkBody do
          begin
            // In version prior to 2 there was a smaller chunk body. Hence we have to read it entry by entry now.
            Stream.Read(ChildCount, SizeOf(ChildCount));
            Stream.Read(NodeHeight, SizeOf(ChildCount));
            // TVirtualNodeStates was a byte sized type in version 1
            States := [];
            Stream.Read(States, SizeOf(Byte));
            // vsVisible is now in the place where vsSelected was before, but every node was visible in the old version
            // so we need to fix this too.
            if vsVisible in States then
              Include(States, vsSelected)
            else
              Include(States, vsVisible);
            Stream.Read(Align, SizeOf(Align));
            Stream.Read(CheckState, SizeOf(CheckState));
            Stream.Read(CheckType, SizeOf(CheckType));
          end;
        end;
        
        with Node^ do
        begin
          NodeHeight := ChunkBody.NodeHeight;
          AdjustTotalHeight(Node, NodeHeight);

          States := ChunkBody.States;
          Align := ChunkBody.Align;
          CheckState := ChunkBody.CheckState;
          CheckType := ChunkBody.CheckType;

          // Create and read child nodes.
          while ChunkBody.ChildCount > 0 do
          begin
            Run := MakeNewNode;
            InternalConnectNode(Run, Node, Self, amAddChildLast);
            ReadNode(Stream, Version, Run);
            Dec(ChunkBody.ChildCount);
          end;
        end;
        Result := True;
      end;
    UserChunk:
      if ChunkSize > 0 then
      begin
        // need to know whether the data was read
        LastPosition := Stream.Position;
        DoLoadUserData(Node, Stream);
        // compare stream position to learn whether the data was read
        Result := Stream.Position > LastPosition;
        // Improve stability by advancing the stream to the chunk's real end if
        // the application did not read what has been written.
        if not Result or (Stream.Position <> (LastPosition + ChunkSize)) then
          Stream.Position := LastPosition + ChunkSize;
      end
      else
        Result := True;
  else
    // unknown chunk, skip it 
    Stream.Position := Stream.Position + ChunkSize;
    Result := False;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.ReadNode(Stream: TStream; Version: Integer; Node: PVirtualNode);

// Reads the anchor chunk of each node and initiates reading the sub chunks for this node

var
  Header: TChunkHeader;
  EndPosition: Integer;

begin
  with Stream do
  begin
    // Read anchor chunk of the node.
    Stream.Read(Header, SizeOf(Header));
    if Header.ChunkType = NodeChunk then
    begin
      EndPosition := Stream.Position + Header.ChunkSize;
      // Read all subchunks until the indicated chunk end position is reached in the stream.
      while Position < EndPosition do
      begin
        // Read new chunk header.
        Stream.Read(Header, SizeOf(Header));
        ReadChunk(Stream, Version, Node, Header.ChunkType, Header.ChunkSize);
      end;
      // If the last chunk does not end at the given end position then there is something wrong.
      if Position <> EndPosition then
        ShowError(SCorruptStream2, hcTFCorruptStream2);
    end
    else
      ShowError(SCorruptStream1, hcTFCorruptStream1);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.RemoveFromSelection(Node: PVirtualNode);

var
  Index: Integer;

begin
  Assert(Assigned(Node), 'Node must not be nil!');
  if vsSelected in Node.States then
  begin
    Exclude(Node.States, vsSelected);
    if FindNodeInSelection(Node, Index, -1, -1) and (Index < FSelectionCount - 1) then
      Move(FSelection[Index + 1], FSelection[Index], (FSelectionCount - Index - 1) * 4);
    Dec(FSelectionCount);
    SetLength(FSelection, FSelectionCount);

    if FSelectionCount = 0 then
      ResetRangeAnchor;
      
    Change(Node);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.RenderOLEData(const FormatEtcIn: TFormatEtc; out Medium: TStgMedium;
  ForClipboard: Boolean): HResult;

// Returns a memory expression of all currently selected nodes in the Medium structure.
// Note: The memory requirement of this method might be very high. This depends however on the requested storage format.
//       For HGlobal (a global memory block) we need to render first all nodes to local memory and copy this then to
//       the global memory in Medium. This is necessary because we have first to determine how much
//       memory is needed before we can allocate it. Hence for a short moment we need twice the space as used by the
//       nodes alone (plus the amount the nodes need in the tree anyway)!
//       With IStream this does not happen. We directly stream out the nodes and pass the constructed stream along.

var
  Data: PCardinal;
  I: Integer;
  ResPointer: Pointer;
  ResSize: Integer;
  Selection: TNodeArray;
  StreamAdapter: TStreamAdapter;

begin
  Selection := nil;

  // We can render the native clipboard format in two different storage media.
  if (FormatEtcIn.cfFormat = CF_VIRTUALTREE) and (FormatEtcIn.tymed and (TYMED_HGLOBAL or TYMED_ISTREAM) <> 0) then
  begin
    try
      // The stream adapter adds not much overhead to the memory stream, so we can create it here and use it
      // for the IStream storage or leave it alone for HGlobal.
      StreamAdapter := TStreamAdapter.Create(TMemoryStream.Create, soOwned);
      if ForClipboard then
        Selection := GetSortedCutCopySet(True)
      else                                               
        Selection := GetSortedSelection(True);
      for I := 0 to High(Selection) do
        WriteNode(StreamAdapter.Stream, Selection[I]);

      Medium.unkForRelease := nil;
      // Return data in one of the supported formats.
      if (FormatEtcIn.tymed and TYMED_ISTREAM) <> 0 then
      begin
        // This one is simple and memory sparing. Just return the IStream interface of the string adapter,
        // but don't free it.
        Medium.tymed := TYMED_ISTREAM;
        // Rewind stream.
        StreamAdapter.Stream.Position := 0;
        IUnknown(Medium.stm) := StreamAdapter as IStream;
        Result := S_OK;
      end
      else
      try
        ResPointer := TMemoryStream(StreamAdapter.Stream).Memory;
        ResSize := StreamAdapter.Stream.Position;

        // Allocate memory to hold the string.
        if ResSize > 0 then
        begin
          Medium.hGlobal := GlobalAlloc(GHND or GMEM_SHARE, ResSize + SizeOf(Cardinal));
          Data := GlobalLock(Medium.hGlobal);
          // Store the size of the data too, for easy retrival.
          Data^ := ResSize;
          Inc(Data);
          Move(ResPointer^, Data^, ResSize);
          GlobalUnlock(Medium.hGlobal);
          Medium.tymed := TYMED_HGLOBAL;

          Result := S_OK;
        end
        else
          Result := E_FAIL;
      finally
        // Since we copied the data to a global memory block we don't need the stream (and the adapter) any longer.
        StreamAdapter.Free;
      end;
    except
      Result := E_FAIL;
    end;
  end
  else // Ask application descentants to render self defined formats.
    Result := DoRenderOLEData(FormatEtcIn, Medium, ForClipboard);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.ResetRangeAnchor;

// Called when there is no selected node anymore and the selection range anchor needs a new value.

begin
  FRangeAnchor := FFocusedNode;
  FLastSelectionLevel := -1;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SelectNodes(StartNode, EndNode: PVirtualNode; AddOnly: Boolean);

// Selects a range of nodes and unselects all other eventually selected nodes which are not in this range if
// AddOnly is False.
// EndNode must be visible while StartNode does not necessarily as in the case where the last focused node is the start
// node but it is a child of a node which has been collapsed previously. In this case the first visible parent node
// is used as start node. StartNode can be nil in which case the very first node in the tree is used.

var
  NodeFrom,
  NodeTo,
  LastAnchor: PVirtualNode;
  Index: Integer;

begin
  Assert(Assigned(EndNode), 'EndNode must not be nil!');
  ClearTempCache;
  if StartNode = nil then
    StartNode := FRoot.FirstChild
  else
    if not FullyVisible[StartNode] then
    begin
      StartNode := GetPreviousVisible(StartNode);
      if StartNode = nil then
        StartNode := FRoot.FirstChild
    end;

  if CompareNodePositions(StartNode, EndNode) < 0 then
  begin
    NodeFrom := StartNode;
    NodeTo := EndNode;
  end
  else
  begin
    NodeFrom := EndNode;
    NodeTo := StartNode;
  end;

  // The range anchor will be reset by the following call.
  LastAnchor := FRangeAnchor;
  if not AddOnly then
    InternalClearSelection;

  while NodeFrom <> NodeTo do
  begin
    InternalCacheNode(NodeFrom);
    NodeFrom := GetNextVisible(NodeFrom);
  end;
  // select last node too
  InternalCacheNode(NodeFrom);
  // now add them all in "one" step
  AddToSelection(FTempNodeCache, FTempNodeCount);
  ClearTempCache;
  if Assigned(LastAnchor) and FindNodeInSelection(LastAnchor, Index, -1, -1) then
   FRangeAnchor := LastAnchor;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SetBiDiMode(Value: TBiDiMode);

begin
  inherited;

  RecreateWnd;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SkipNode(Stream: TStream);

// Skips the data for the next node in the given stream (including the child nodes).

var
  Header: TChunkHeader;

begin
  with Stream do
  begin
    // read achor chunk of the node
    Stream.Read(Header, SizeOf(Header));
    if Header.ChunkType = NodeChunk then
      Stream.Position := Stream.Position + Header.ChunkSize
    else
      ShowError(SCorruptStream1, hcTFCorruptStream1);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

var
  PanningWindowClass: TWndClass = (
    style: 0;
    lpfnWndProc: @DefWindowProc;
    cbClsExtra: 0;
    cbWndExtra: 0;
    hInstance: 0;
    hIcon: 0;
    hCursor: 0;
    hbrBackground: 0;
    lpszMenuName: nil;
    lpszClassName: 'VTPanningWindow'
  );

procedure TBaseVirtualTree.StartWheelPanning(Position: TPoint);

// Called when wheel panning should start. A little helper window is created to indicate the reference position,
// which determines in which direction and how far wheel panning/scrolling will happen.

  //--------------- local function --------------------------------------------

  function CreateClipRegion: HRGN;

  // In order to avoid doing all the transparent drawing ourselves we use a
  // window region for the wheel window.
  // Since we only work on a very small image (32x32 pixels) this is acceptable.

  var
    Start, X, Y: Integer;
    Temp: HRGN;
    
  begin
    Assert(not FPanningImage.Empty, 'Invalid wheel panning image.');

    // Create an initial region on which we operate.
    Result := CreateRectRgn(0, 0, 0, 0);
    with FPanningImage, Canvas do
    begin
      for Y := 0 to Height - 1 do
      begin
        Start := -1;
        for X := 0 to Width - 1 do
        begin
          // Start a new span if we found a non-transparent pixel and no span is currently started.
          if (Start = -1) and (Pixels[X, Y] <> clFuchsia) then
            Start := X
          else
            if (Start > -1) and (Pixels[X, Y] = clFuchsia) then
            begin
              // A non-transparent span is finished. Add it to the result region.
              Temp := CreateRectRgn(Start, Y, X, Y + 1);
              CombineRgn(Result, Result, Temp, RGN_OR);
              DeleteObject(Temp);
              Start := -1;
            end;
        end;
        // If there is an open span then add this also to the result region.
        if Start > -1 then
        begin
          Temp := CreateRectRgn(Start, Y, Width, Y + 1);
          CombineRgn(Result, Result, Temp, RGN_OR);
          DeleteObject(Temp);
        end;
      end;
    end;
    // The resulting region is used as window region so we must not delete it.
    // Windows will own it after the assignment below.
  end;

  //--------------- end local function ----------------------------------------

var
  TempClass: TWndClass;
  ClassRegistered: Boolean;
  ImageName: string;
  
begin
  // Set both panning and scrolling flag. One will be removed shortly depending on whether the middle mouse button is
  // released before the mouse is moved or vice versa. The first case is referred to as wheel scrolling while the
  // latter is called wheel panning.
  StopTimer(ScrollTimer);
  FStates := FStates + [tsWheelPanning, tsWheelScrolling, tsScrolling];

  // Register the helper window class.
  PanningWindowClass.hInstance := HInstance;
  ClassRegistered := GetClassInfo(HInstance, PanningWindowClass.lpszClassName, TempClass);
  if not ClassRegistered or (TempClass.lpfnWndProc <> @DefWindowProc) then
  begin
    if ClassRegistered then
      Windows.UnregisterClass(PanningWindowClass.lpszClassName, HInstance);
    Windows.RegisterClass(PanningWindowClass);
  end;
  // Create the helper window and show at the given position without activating it.
  with ClientToScreen(Position) do
    FPanningWindow := CreateWindowEx(WS_EX_TOOLWINDOW, PanningWindowClass.lpszClassName, nil, WS_POPUP, X - 16, Y - 16,
      32, 32, Handle, 0, HInstance, nil);

  FPanningImage := TBitmap.Create;
  if Integer(FRangeX) > ClientWidth then
  begin
    if Integer(FRangeY) > ClientHeight then
      ImageName := 'VT_MOVEALL'
    else
      ImageName := 'VT_MOVEEW'
  end
  else
    ImageName := 'VT_MOVENS';
  FPanningImage.LoadFromResourceName(HInstance, ImageName);
  SetWindowRgn(FPanningWindow, CreateClipRegion, False);

  {$ifdef COMPILER_6_UP}
    SetWindowLong(FPanningWindow, GWL_WNDPROC, Integer(Classes.MakeObjectInstance(PanningWindowProc)));
  {$else}
    SetWindowLong(FPanningWindow, GWL_WNDPROC, Integer(MakeObjectInstance(PanningWindowProc)));
  {$endif}
  ShowWindow(FPanningWindow, SW_SHOWNOACTIVATE);

  // Setup the panscroll timer and capture all mouse input.
  SetFocus;
  SetCapture(Handle);
  SetTimer(Handle, ScrollTimer, 20, nil);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.StopWheelPanning;

// Stops panning if currently active and destroys the helper window.

var
  Instance: Pointer;

begin
  if [tsWheelPanning, tsWheelScrolling] * FStates <> [] then
  begin
    // Release the mouse capture and stop the panscroll timer.
    StopTimer(ScrollTimer);
    ReleaseCapture;
    FStates := FStates - [tsWheelPanning, tsWheelScrolling];

    // Destroy the helper window.
    Instance := Pointer(GetWindowLong(FPanningWindow, GWL_WNDPROC));
    DestroyWindow(FPanningWindow);
    if Instance <> @DefWindowProc then
      {$ifdef COMPILER_6_UP}
        Classes.FreeObjectInstance(Instance);
      {$else}
        FreeObjectInstance(Instance);
      {$endif}
    FPanningWindow := 0;
    FPanningImage.Free;
    FPanningImage := nil;
    DeleteObject(FPanningCursor);
    FPanningCursor := 0;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.StructureChange(Node: PVirtualNode; Reason: TChangeReason);

begin
  AdviseChangeEvent(True, Node, Reason);

  if FUpdateCount = 0 then
  begin
    if (FChangeDelay > 0) and not (tsSynchMode in FStates) then
      SetTimer(Handle, StructureChangeTimer, FChangeDelay, nil)
    else
      DoStructureChange(Node, Reason);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.SuggestDropEffect(Source: TObject; Shift: TShiftState; Pt: TPoint;
  AllowedEffects: Integer): Integer;

// determines the drop action to take if the drag'n drop operation ends on this tree
// Note: Source can be any Delphi object not just a virtual tree

begin
  Result := AllowedEffects;

  // prefer MOVE if source and target are the same control, otherwise whatever is allowed as initial value
  if Assigned(Source) and (Source = Self) then
    if (AllowedEffects and DROPEFFECT_MOVE) <> 0 then
      Result := DROPEFFECT_MOVE
    else // no change
  else
    // drag between different applicatons
    if (AllowedEffects and DROPEFFECT_COPY) <> 0 then
      Result := DROPEFFECT_COPY;

  // consider modifier keys and what is allowed at the moment, if none of the following conditions apply then
  // the initial value just set is used
  if ssCtrl in Shift then
  begin
    // copy or link
    if ssShift in Shift then
    begin
      // link
      if (AllowedEffects and DROPEFFECT_LINK) <> 0 then
        Result := DROPEFFECT_LINK;
    end
    else
    begin
      // copy
      if (AllowedEffects and DROPEFFECT_COPY) <> 0 then
        Result := DROPEFFECT_COPY;
    end;
  end
  else
  begin
    // move, link or default
    if ssShift in Shift then
    begin
      // move
      if (AllowedEffects and DROPEFFECT_MOVE) <> 0 then
        Result := DROPEFFECT_MOVE;
    end
    else
    begin
      // link or default
      if ssAlt in Shift then
      begin
        // link
        if (AllowedEffects and DROPEFFECT_LINK) <> 0 then
          Result := DROPEFFECT_LINK;
      end;
      // else default
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.ToggleSelection(StartNode, EndNode: PVirtualNode);

// Switchs the selection state of a range of nodes.
// Note: This method is specifically designed to help selecting ranges with the keyboard and considers therefore
//       the range anchor.

var
  NodeFrom,
  NodeTo: PVirtualNode;
  NewSize: Integer;
  Position: Integer;

begin
  Assert(Assigned(EndNode), 'EndNode must not be nil!');
  if StartNode = nil then
    StartNode := FRoot.FirstChild
  else
    if not FullyVisible[StartNode] then
      StartNode := GetPreviousVisible(StartNode);

  Position := CompareNodePositions(StartNode, EndNode);
  // nothing to do if start and end node are the same
  if Position <> 0 then
  begin
    if Position < 0 then
    begin
      NodeFrom := StartNode;
      NodeTo := EndNode;
    end
    else
    begin
      NodeFrom := EndNode;
      NodeTo := StartNode;
    end;

    ClearTempCache;

    // 1) toggle the start node if it is before the range anchor
    if CompareNodePositions(NodeFrom, FRangeAnchor) < 0 then
      if not (vsSelected in NodeFrom.States) then
        InternalCacheNode(NodeFrom)
      else
        InternalRemoveFromSelection(NodeFrom);

    // 2) toggle all nodes within the range
    NodeFrom := GetNextVisible(NodeFrom);
    while NodeFrom <> NodeTo do
    begin
      if not (vsSelected in NodeFrom.States) then
        InternalCacheNode(NodeFrom)
      else
        InternalRemoveFromSelection(NodeFrom);
      NodeFrom := GetNextVisible(NodeFrom);
    end;

    // 3) toggle end node if it is after the range anchor
    if CompareNodePositions(NodeFrom, FRangeAnchor) > 0 then
      if not (vsSelected in NodeFrom.States) then
        InternalCacheNode(NodeFrom)
      else
        InternalRemoveFromSelection(NodeFrom);

    // Do some housekeeping if there was a change.
    NewSize := PackArray(FSelection, FSelectionCount);
    if NewSize > -1 then
    begin
      FSelectionCount := NewSize;
      SetLength(FSelection, FSelectionCount);
    end;
    // If the range went over the anchor then we need to reselect it.
    if not (vsSelected in FRangeAnchor.States) then
      InternalCacheNode(FRangeAnchor);
    if FTempNodeCount > 0 then
      AddToSelection(FTempNodeCache, FTempNodeCount);
    ClearTempCache;

  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.UnselectNodes(StartNode, EndNode: PVirtualNode);

// Deselects a range of nodes.
// EndNode must be visible while StartNode must not as in the case where the last focused node is the start node
// but it is a child of a node which has been collapsed previously. In this case the first visible parent node
// is used as start node. StartNode can be nil in which case the very first node in the tree is used.

var
  NodeFrom,
  NodeTo: PVirtualNode;
  NewSize: Integer;

begin
  Assert(Assigned(EndNode), 'EndNode must not be nil!');
  
  if StartNode = nil then
    StartNode := FRoot.FirstChild
  else
    if not FullyVisible[StartNode] then
    begin
      StartNode := GetPreviousVisible(StartNode);
      if StartNode = nil then
        StartNode := FRoot.FirstChild
    end;

  if CompareNodePositions(StartNode, EndNode) < 0 then
  begin
    NodeFrom := StartNode;
    NodeTo := EndNode;
  end
  else
  begin
    NodeFrom := EndNode;
    NodeTo := StartNode;
  end;

  while NodeFrom <> NodeTo do
  begin
    InternalRemoveFromSelection(NodeFrom);
    NodeFrom := GetNextVisible(NodeFrom);
  end;
  // Deselect last node too.
  InternalRemoveFromSelection(NodeFrom);

  // Do some housekeeping.
  NewSize := PackArray(FSelection, FSelectionCount);
  if NewSize > -1 then
  begin
    FSelectionCount := NewSize;
    SetLength(FSelection, FSelectionCount);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.UpdateDesigner;

var
  ParentForm: TCustomForm;

begin
  if (csDesigning in ComponentState) and not (csUpdating in ComponentState) then
  begin
    ParentForm := GetParentForm(Self);
    if Assigned(ParentForm) and Assigned(ParentForm.Designer) then
      ParentForm.Designer.Modified;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.UpdateHeaderRect;

// Calculates the rectangle the header occupies in non-client area.
// These coordinates are in window rectangle.

var
  OffsetX,
  OffsetY: Integer;
  EdgeSize: Integer;
  Styles: Integer;

begin
  if hoVisible in FHeader.FOptions then
  begin
    FHeaderRect := Rect(0, 0, Width, Height);

    // Consider borders...
    Styles := GetWindowLong(Handle, GWL_STYLE);
    if (Styles and WS_BORDER) <> 0 then
      InflateRect(FHeaderRect, -1, -1);
    if (Styles and WS_THICKFRAME) <> 0 then
      InflateRect(FHeaderRect, -3, -3);

    Styles := GetWindowLong(Handle, GWL_EXSTYLE);
    if (Styles and WS_EX_CLIENTEDGE) <> 0 then
      InflateRect(FHeaderRect, -2, -2);

    // ... and bevels.
    OffsetX := BorderWidth;
    OffsetY := BorderWidth;
    if BevelKind <> bkNone then
    begin
      EdgeSize := 0;
      if BevelInner <> bvNone then
        Inc(EdgeSize, BevelWidth);
      if BevelOuter <> bvNone then
        Inc(EdgeSize, BevelWidth);
      if beLeft in BevelEdges then
        Inc(OffsetX, EdgeSize);
      if beTop in BevelEdges then
        Inc(OffsetY, EdgeSize);
    end;

    InflateRect(FHeaderRect, -OffsetX, -OffsetY);
    if FHeaderRect.Left <= FHeaderRect.Right then
      FHeaderRect.Bottom := FHeaderRect.Top + Integer(FHeader.FHeight)
    else
      FHeaderRect := Rect(0, 0, 0, 0);
  end
  else
    FHeaderRect := Rect(0, 0, 0, 0);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.UpdateEditBounds;

// Used to update the bounds of the current node editor if editing is currently active.

var
  R: TRect;
  Dummy: Integer;
  BidiMode: TBidiMode;

begin
  if tsEditing in FStates then
  begin
    R := GetDisplayRect(FFocusedNode, FEditColumn, True, True);
    if (toGridExtensions in FOptions.MiscOptions) then
    begin
      // Consider visible tree lines, check boxes or images here. Do not forget about bidi.
      if FEditColumn = NoColumn then
        BidiMode := Self.BidiMode
      else
        BidiMode := FHeader.Columns[FEditColumn].FBiDiMode;
      if BiDiMode = bdLeftToRight then
        FHeader.Columns.GetColumnBounds(FEditColumn, Dummy, R.Right)
      else
        FHeader.Columns.GetColumnBounds(FEditColumn, R.Left, Dummy);
    end;
    if toShowHorzGridLines in TreeOptions.PaintOptions then
      Dec(R.Bottom);
    FEditLink.SetBounds(R);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

const
  ScrollMasks: array[Boolean] of Cardinal = (0, SIF_DISABLENOSCROLL);

const // Region identifiers for GetRandomRgn
  CLIPRGN = 1;
  METARGN = 2;
  APIRGN = 3;
  SYSRGN = 4;

function GetRandomRgn(DC: HDC; Rgn: HRGN; iNum: Integer): Integer; stdcall; external 'GDI32.DLL';

procedure TBaseVirtualTree.UpdateWindowAndDragImage(const Tree: TBaseVirtualTree; TreeRect: TRect; UpdateNCArea,
  ReshowDragImage: Boolean);

// Method to repaint part of the window area which is not covered by the drag image and to initiate a recapture
// of the drag image.
// Note: This method must only be called during a drag operation and the tree passed in is the one managing the current
// drag image (so it is the actual drag source).

var
  DragRegion,          // the region representing the drag image
  UpdateRegion,        // the unclipped region within the tree to be updated
  NCRegion: HRGN;      // the region representing the non-client area of the tree
  DragRect,
  NCRect: TRect;
  RedrawFlags: Cardinal;

  VisibleTreeRegion: HRGN;

  DC: HDC;

begin
  if IntersectRect(TreeRect, TreeRect, ClientRect) then
  begin
    // Retrieve the visible region of the window. This important to avoid overpainting parts of other windows
    // which overlap this one.
    VisibleTreeRegion := CreateRectRgn(0, 0, 1, 1);
    DC := GetDCEx(Handle, 0, DCX_CACHE or DCX_WINDOW or DCX_CLIPSIBLINGS or DCX_CLIPCHILDREN);
    GetRandomRgn(DC, VisibleTreeRegion, SYSRGN);
    ReleaseDC(Handle, DC);

    // In Win9x the returned visible region is given in client coordinates. We need it in screen coordinates, though.
    if not IsWinNT then
      with ClientToScreen(Point(0, 0)) do
        OffsetRgn(VisibleTreeRegion, X, Y);

    // The drag image will figure out itself what part of the rectangle can be recaptured.
    // Recapturing is not done by taking a snapshot of the screen, but by letting the tree draw itself
    // into the back bitmap of the drag image. So the order here is unimportant.
    Tree.FDragImage.RecaptureBackground(Self, TreeRect, VisibleTreeRegion, UpdateNCArea, ReshowDragImage);

    // Calculate the screen area not covered by the drag image and which needs an update.
    DragRect := Tree.FDragImage.GetDragImageRect;
    MapWindowPoints(0, Handle, DragRect, 2);
    DragRegion := CreateRectRgnIndirect(DragRect);
                             
    // Start with non-client area if requested.
    if UpdateNCArea then
    begin
      // Compute the part of the non-client area which must be updated.

      // Determine the outer rectangle of the entire tree window.
      GetWindowRect(Handle, NCRect);
      // Express the tree window rectangle in client coordinates (because RedrawWindow wants them so).
      MapWindowPoints(0, Handle, NCRect, 2);
      NCRegion := CreateRectRgnIndirect(NCRect);
      // Determine client rect in screen coordinates and create another region for it.
      UpdateRegion := CreateRectRgnIndirect(ClientRect);
      // Create a region which only contains the NC part by subtracting out the client area.
      CombineRgn(NCRegion, NCRegion, UpdateRegion, RGN_DIFF);
      // Subtract also out what is hidden by the drag image.
      CombineRgn(NCRegion, NCRegion, DragRegion, RGN_DIFF);
      RedrawWindow(Handle, nil, NCRegion, RDW_FRAME or RDW_NOERASE or RDW_NOCHILDREN or RDW_INVALIDATE or RDW_VALIDATE or
        RDW_UPDATENOW);
      DeleteObject(NCRegion);
      DeleteObject(UpdateRegion);
    end;

    UpdateRegion := CreateRectRgnIndirect(TreeRect);
    RedrawFlags := RDW_INVALIDATE or RDW_VALIDATE or RDW_UPDATENOW or RDW_NOERASE or RDW_NOCHILDREN;
    // Remove the part of the update region which is covered by the drag image.
    CombineRgn(UpdateRegion, UpdateRegion, DragRegion, RGN_DIFF);
    RedrawWindow(Handle, nil, UpdateRegion, RedrawFlags);
    DeleteObject(UpdateRegion);
    DeleteObject(DragRegion);
    DeleteObject(VisibleTreeRegion);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.ValidateCache;

// Starts cache validation if not already done by adding this instance to the worker thread's waiter list
// (if not already there) and signalling the thread it can start validating.

begin
  // Wait for thread to stop validation if it is currently validating this tree's cache.
  InterruptValidation;
  
  if WorkerThread=nil then exit;

  FStartIndex := 0;
  if tsValidationNeeded in FStates then
  begin
    // Tell the thread this tree needs actually something to do.
    WorkerThread.AddTree(Self);
    SetEvent(WorkEvent);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.ValidateNodeDataSize(var Size: Integer);

begin
  Size := 0;
  if Assigned(FOnGetNodeDataSize) then
    FOnGetNodeDataSize(Self, Size);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WndProc(var Message: TMessage);

var
  Handled: Boolean;

begin
  Handled := False;

  // Try the header whether it needs to take this message.
  if Assigned(FHeader) and (FHeader.FStates <> []) then
    Handled := FHeader.HandleMessage(Message);
  if not Handled then
  begin
    // For auto drag mode, let tree handle itself, instead of TControl.
    if not (csDesigning in ComponentState) and
       ((Message.Msg = WM_LBUTTONDOWN) or (Message.Msg = WM_LBUTTONDBLCLK)) then
    begin
      if (DragMode = dmAutomatic) and (DragKind = dkDrag) then
      begin
        if IsControlMouseMsg(TWMMouse(Message)) then
          Handled := True;
        if not Handled then
        begin
          ControlState := ControlState + [csLButtonDown];
          Dispatch(Message);  // overrides TControl's BeginDrag
          Handled := True;
        end;
      end;
    end;

    if not Handled and Assigned(FHeader) then
      Handled := FHeader.HandleMessage(Message);

    if not Handled then
    begin
      if (Message.Msg in [WM_NCLBUTTONDOWN, WM_NCRBUTTONDOWN, WM_NCMBUTTONDOWN]) and not Focused and CanFocus then
        SetFocus;
      inherited;
    end;
  end;
end;                    

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WriteChunks(Stream: TStream; Node: PVirtualNode);

// writes the core chunks for Node into the stream
// Node: Descentants can optionally override this method to add other node specific chunks.
//       Keep in mind that this method is also called for the root node. Using this fact in descentants you can
//       create a kind of "global" chunks not directly bound to a specific node.

var
  Header: TChunkHeader;
  LastPosition,
  ChunkSize: Integer;
  Chunk: TBaseChunk;
  Run: PVirtualNode;

begin
  with Stream do
  begin
    // 1. The base chunk...
    LastPosition := Position;
    Chunk.Header.ChunkType := BaseChunk;
    with Node^, Chunk do
    begin
      Body.ChildCount := ChildCount;
      Body.NodeHeight := NodeHeight;
      // some states are only temporary so take them out as they make no sense at the new location
      Body.States := States - [vsChecking, vsCutOrCopy, vsDeleting, vsInitialUserData];
      Body.Align := Align;
      Body.CheckState := CheckState;
      Body.CheckType := CheckType;
      Body.Reserved := 0;
    end;
    // write the base chunk
    Write(Chunk, SizeOf(Chunk));

    // 2. ... directly followed by the child node chunks (actually they are child chunks of
    //   the base chunk)
    if vsInitialized in Node.States then
    begin
      Run := Node.FirstChild;
      while Assigned(Run) do
      begin
        WriteNode(Stream, Run);
        Run := Run.NextSibling;
      end;
    end;
    
    FinishChunkHeader(Stream, LastPosition, Position);

    // 3. write user data
    LastPosition := Position;
    Header.ChunkType := UserChunk;
    Write(Header, SizeOf(Header));
    DoSaveUserData(Node, Stream);
    // check if the application actually wrote data
    ChunkSize := Position - LastPosition - SizeOf(TChunkHeader);
    // seek back to start of chunk if nothing has been written 
    if ChunkSize = 0 then
    begin
      Position := LastPosition;
      Size := Size - SizeOf(Header);
    end
    else
      FinishChunkHeader(Stream, LastPosition, Position);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.WriteNode(Stream: TStream; Node: PVirtualNode);

// Writes the "cover" chunk for Node to Stream and initiates writing child nodes and chunks.

var
  LastPosition: Integer;
  Header: TChunkHeader;
  
begin
  // Initialize the node first if necessary and wanted.
  if toInitOnSave in FOptions.FMiscOptions then
  begin
    if not (vsInitialized in Node.States) then
      InitNode(Node);
    if (vsHasChildren in Node.States) and (Node.ChildCount = 0) then
      InitChildren(Node);
  end;

  with Stream do
  begin
    LastPosition := Position;
    // Emit the anchor chunk.
    Header.ChunkType := NodeChunk;
    Write(Header, SizeOf(Header));
    // Write other chunks to stream taking their size into this chunk's size.
    WriteChunks(Stream, Node);

    // Update chunk size.
    FinishChunkHeader(Stream, LastPosition, Position);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.AbsoluteIndex(Node: PVirtualNode): Cardinal;

begin
  Result := 0;
  while Assigned(Node) and (Node <> FRoot) do
  begin
    if not (vsInitialized in Node.States) then
      InitNode(Node);
    if Assigned(Node.PrevSibling) then
    begin
      // if there's a previous sibling then add its total count to the result
      Node := Node.PrevSibling;
      Inc(Result, Node.TotalCount);
    end
    else
    begin
      Node := Node.Parent;
      if Node <> FRoot then
        Inc(Result);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.AddChild(Parent: PVirtualNode; UserData: Pointer = nil): PVirtualNode;

// Adds a new node to the given parent node. This is simply done by increasing the child count of the
// parent node. If Parent is nil then the new node is added as (last) top level node.
// UserData can be used to set the first 4 bytes of the user data area to an initial value which can be used
// in OnInitNode and will also cause to trigger the OnFreeNode event (if <> nil) even if the node is not yet
// "officially" initialized.
// AddChild is a compatibility method and will implicitly validate the parent node. This is however
// against the virtual paradigm and hence I dissuade from its usage.

var
  NodeData: ^Pointer;

begin
  CancelEditNode;

  if Parent = nil then
    Parent := FRoot;
  if not (vsInitialized in Parent.States) then
    InitNode(Parent);

  // Locally stop updates of the tree in order to avoid usage of the new node before it is correctly set up.
  // If the update count was 0 on enter then there will be a correct update at the end of this method.
  Inc(FUpdateCount);
  try
    SetChildCount(Parent, Parent.ChildCount + 1);
  finally
    Dec(FUpdateCount);
  end;
  Result := Parent.LastChild;

  // Check if there is initial user data and there is also enough user data space allocated.
  if Assigned(UserData) then
    if FNodeDataSize >= 4 then
    begin
      NodeData := Pointer(PChar(@Result.Data) + FTotalInternalDataSize);
      NodeData^ := UserData;
      Include(Result.States, vsInitialUserData);
    end
    else
      ShowError(SCannotSetUserData, hcTFCannotSetUserData);

  if FUpdateCount = 0 then
  begin
    ValidateCache;
    if tsStructureChangePending in FStates then
    begin
      if Parent = FRoot then
        StructureChange(nil, crChildAdded)
      else
        StructureChange(Parent, crChildAdded);
    end;

    if (toAutoSort in FOptions.FAutoOptions) and (FHeader.FSortColumn > InvalidColumn) then
      Sort(Parent, FHeader.FSortColumn, FHeader.FSortDirection, True);

    InvalidateToBottom(Parent);
    UpdateScrollbars(True);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.AddFromStream(Stream: TStream; TargetNode: PVirtualNode);

// loads nodes from the given stream and adds them to TargetNode
// the current content is not cleared before the load process starts (see also LoadFromStream)

var
  ThisID: TMagicID;
  Version,
  Count: Cardinal;
  Node: PVirtualNode;

begin
  // check first whether this is a stream we can read
  Stream.ReadBuffer(ThisID, SizeOf(TMagicID));
  if (ThisID[0] = MagicID[0]) and
     (ThisID[1] = MagicID[1]) and
     (ThisID[2] = MagicID[2]) and
     (ThisID[5] = MagicID[5]) then
  begin
    Version := Word(ThisID[3]);
    if Version <= VTTreeStreamVersion  then
    begin
      BeginUpdate;
      try
        if Version < 2 then
          Count := MaxInt
        else
          Stream.ReadBuffer(Count, SizeOf(Count));

        while (Stream.Position < Stream.Size) and (Count > 0) do
        begin
          Dec(Count);
          Node := MakeNewNode;
          InternalConnectNode(Node, TargetNode, Self, amAddChildLast);
          InternalAddFromStream(Stream, Version, Node);
        end;
        if TargetNode = FRoot then
          DoNodeCopied(nil)
        else
          DoNodeCopied(TargetNode);
      finally
        EndUpdate;
      end;
    end
    else
      ShowError(SWrongStreamVersion, hcTFWrongStreamVersion);
  end
  else
    ShowError(SWrongStreamVersion, hcTFWrongStreamVersion);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.AfterConstruction;

begin
  inherited;

  if FRoot = nil then
    InitRootNode;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.Assign(Source: TPersistent);

begin
  if Source is TBaseVirtualTree then
    with Source as TBaseVirtualTree do
    begin
      Self.Align := Align;
      Self.Anchors := Anchors;
      Self.AutoScrollDelay := AutoScrollDelay;
      Self.AutoScrollInterval := AutoScrollInterval;
      Self.AutoSize := AutoSize;
      Self.Background := Background;
      Self.BevelEdges := BevelEdges;
      Self.BevelInner := BevelInner;
      Self.BevelKind := BevelKind;
      Self.BevelOuter := BevelOuter;
      Self.BevelWidth := BevelWidth;
      Self.BiDiMode := BiDiMode;
      Self.BorderStyle := BorderStyle;
      Self.BorderWidth := BorderWidth;
      Self.ChangeDelay := ChangeDelay;
      Self.CheckImageKind := CheckImageKind;
      Self.Color := Color;
      Self.Colors.Assign(Colors);
      Self.Constraints := Constraints;
      Self.Ctl3D := Ctl3D;
      Self.DefaultNodeHeight := DefaultNodeHeight;
      Self.DefaultPasteMode := DefaultPasteMode;
      Self.DragCursor := DragCursor;
      Self.DragImageKind := DragImageKind;
      Self.DragKind := DragKind;
      Self.DragMode := DragMode;
      Self.Enabled := Enabled;
      Self.Font := Font;
      Self.Header := Header;
      Self.HintAnimation := HintAnimation;
      Self.HintMode := HintMode;
      Self.HotCursor := HotCursor;
      Self.Images := Images;
      Self.ImeMode := ImeMode;
      Self.ImeName := ImeName;
      Self.Indent := Indent;
      Self.Margin := Margin;
      Self.NodeAlignment := NodeAlignment;
      Self.NodeDataSize := NodeDataSize;
      Self.TreeOptions := TreeOptions;
      Self.ParentBiDiMode := ParentBiDiMode;
      Self.ParentColor := ParentColor;
      Self.ParentCtl3D := ParentCtl3D;
      Self.ParentFont := ParentFont;
      Self.ParentShowHint := ParentShowHint;
      Self.PopupMenu := PopupMenu;            
      Self.RootNodeCount := RootNodeCount;
      Self.ScrollBarOptions := ScrollBarOptions;
      Self.ShowHint := ShowHint;
      Self.StateImages := StateImages;
      Self.TabOrder := TabOrder;
      Self.TabStop := TabStop;
      Self.Visible := Visible;
      Self.SelectionCurveRadius := SelectionCurveRadius;
    end
    else
      inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.BeginDrag(Immediate: Boolean; Threshold: Integer);

// Reintroduced method to allow to start OLE drag'n drop as well as VCL drag'n drop.

begin
  if FDragType = dtVCL then
  begin
    Include(FStates, tsVCLDragPending);
    inherited;
  end
  else
    if (FStates * [tsOLEDragPending, tsOLEDragging]) = [] then
    begin
      // Drag start position has already been recorded in WMMouseDown.
      if Threshold < 0 then
        FDragThreshold := Mouse.DragThreshold
      else
        FDragThreshold := Threshold;
      if Immediate then
        DoDragging(FLastClickPos)
      else
        Include(FStates, tsOLEDragPending);
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.BeginSynch;

// Starts the synchronous update mode (if not already active).

begin
  if not (csDestroying in ComponentState) then
  begin
    if FSynchUpdateCount = 0 then
    begin
      DoUpdating(usBeginSynch);

      // Stop all timers...
      StopTimer(ChangeTimer);
      StopTimer(StructureChangeTimer);
      StopTimer(ExpandTimer);
      StopTimer(EditTimer);
      Exclude(FStates, tsEditPending);
      StopTimer(HeaderTimer);
      FStates := FStates - [tsScrollPending, tsScrolling];
      StopTimer(ScrollTimer);
      StopTimer(SearchTimer);
      Exclude(FStates, tsIncrementalSearching);

      // ...and trigger pending update states.
      if tsStructureChangePending in FStates then
        DoStructureChange(FLastStructureChangeNode, FLastStructureChangeReason);
      if tsChangePending in FStates then
        DoChange(FLastChangedNode);
    end
    else
      DoUpdating(usSynch);
  end;
  Inc(FSynchUpdateCount);
  Include(FStates, tsSynchMode);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.BeginUpdate;

begin
  if not (csDestroying in ComponentState) then
  begin
    if FUpdateCount = 0 then
    begin
      DoUpdating(usBegin);
      SetUpdateState(True);
    end
    else
      DoUpdating(usUpdate);
  end;
  Inc(FUpdateCount);
  Include(FStates, tsUpdating);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.CancelCutOrCopy;

// Resets nodes which are marked as being cut.

var
  Run: PVirtualNode;

begin
  if ([tsCutPending, tsCopyPending] * FStates) <> [] then
  begin
    Run := FRoot.FirstChild;
    while Assigned(Run) do
    begin
      if vsCutOrCopy in Run.States then
        Exclude(Run.States, vsCutOrCopy);
      Run := GetNextNoInit(Run);
    end;
  end;
  FStates := FStates - [tsCutPending, tsCopyPending];
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.CancelEditNode: Boolean;

// called by the application or the current edit link to cancel the edit action

begin
  if HandleAllocated and ([tsEditing, tsEditPending] * FStates <> []) then
    Result := DoCancelEdit
  else
    Result := True;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.Clear;

begin 
  BeginUpdate;
  try
    InterruptValidation;
    if IsEditing then
      CancelEditNode;

    if ClipboardStates * FStates <> [] then
    begin
      OleSetClipBoard(nil);
      FStates := FStates - ClipboardStates;
    end;
    ClearSelection;
    FFocusedNode := nil;
    FLastSelected := nil;
    FCurrentHotNode := nil;
    DeleteChildren(FRoot);
    FRoot.FirstChild := nil;
    FRoot.LastChild := nil;
    FVisibleCount := 0;
    FOffsetX := 0;
    FOffsetY := 0;
  finally
    EndUpdate;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.ClearSelection;

var
  Node: PVirtualNode;
  Dummy: Integer;
  R: TRect;
  Counter: Integer;
  
begin
  if (FSelectionCount > 0) and not (csDestroying in ComponentState) then
  begin
    if (FUpdateCount = 0) and HandleAllocated and (FVisibleCount > 0) then
    begin
      // Iterate through nodes currently visible in the client area and invalidate them.
      Node := GetNodeAt(0, 0, True, Dummy);
      if Assigned(Node) then
        R := GetDisplayRect(Node, NoColumn, False);
      Counter := FSelectionCount;

      while Assigned(Node) do
      begin
        if vsSelected in Node.States then
        begin
          InvalidateRect(Handle, @R, False);
          Dec(Counter);
          // Only try as many nodes as are selected.
          if Counter = 0 then
            Break;
        end;
        OffsetRect(R, 0, Node.NodeHeight);
        if R.Top > ClientHeight then
          Break;
        Node := GetNextVisibleNoInit(Node);
      end;
    end;

    InternalClearSelection;
    Change(nil);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.CopyTo(Source: PVirtualNode; Tree: TBaseVirtualTree; Mode: TVTNodeAttachMode;
  ChildrenOnly: Boolean): PVirtualNode;

// A simplified CopyTo method to allow to copy nodes to the root of another tree.

begin
  Result := CopyTo(Source, Tree.FRoot, Mode, ChildrenOnly);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.CopyTo(Source, Target: PVirtualNode; Mode: TVTNodeAttachMode;
  ChildrenOnly: Boolean): PVirtualNode;

// Copies Source and all its child nodes to Target.
// Mode is used to specify further where to add the new node actually (as sibling of Target or as child of Target).
// Result is the newly created node to which source has been copied if ChildrenOnly is False or just contains Target
// in the other case.
// ChildrenOnly determines whether to copy also the source node or only its child nodes.

var
  TargetTree: TBaseVirtualTree;
  Stream: TMemoryStream;
  
begin
  Assert(TreeFromNode(Source) = Self, 'The source tree must contain the source node.');

  Result := nil;
  if (Mode <> amNoWhere) and Assigned(Source) and (Source <> FRoot) then
  begin
    // Assume that an empty destination means the root in this (the source) tree.
    if Target = nil then
    begin
      TargetTree := Self;
      Target := FRoot;
      Mode := amAddChildFirst;
    end
    else
      TargetTree := TreeFromNode(Target);

    if Target = TargetTree.FRoot then
    begin
      case Mode of
        amInsertBefore:
          Mode := amAddChildFirst;
        amInsertAfter:
          Mode := amAddChildLast;
      end;
    end;

    Stream := TMemoryStream.Create;
    try
      // Write all nodes into a temprary stream depending on the ChildrenOnly flag.
      if not ChildrenOnly then
        WriteNode(Stream, Source)
      else
      begin
        Source := Source.FirstChild;
        while Assigned(Source) do
        begin
          WriteNode(Stream, Source);
          Source := Source.NextSibling;
        end;
      end;
      // Now load the serialized nodes into the target node (tree).
      TargetTree.BeginUpdate;
      try
        Stream.Position := 0;
        while Stream.Position < Stream.Size do
        begin
          Result := MakeNewNode;
          InternalConnectNode(Result, Target, TargetTree, Mode);
          TargetTree.InternalAddFromStream(Stream, VTTreeStreamVersion, Result);
          if not DoNodeCopying(Result, Target) then
            TargetTree.DeleteNode(Result)
          else
            DoNodeCopied(Result);
        end;
        if ChildrenOnly then
          Result := Target;
      finally
        TargetTree.EndUpdate;
      end;
    finally
      Stream.Free;
    end;

    with TargetTree do
    begin
      InvalidateCache;
      if FUpdateCount = 0 then
      begin
        ValidateCache;
        UpdateScrollBars(True);
        Invalidate;
      end;
      StructureChange(Source, crNodeCopied);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.CopyToClipBoard;

var
  DataObject: IDataObject;

begin
  if FSelectionCount > 0 then
  begin
    DataObject := TVTDataObject.Create(Self, True) as IDataObject;
    if OleSetClipBoard(DataObject) = S_OK then
    begin
      MarkCutCopyNodes;
      Include(FStates, tsCopyPending);
      Invalidate;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.CutToClipBoard;

var
  DataObject: IDataObject;

begin
  if FSelectionCount > 0 then
  begin
    DataObject := TVTDataObject.Create(Self, True) as IDataObject;
    if OleSetClipBoard(DataObject) = S_OK then
    begin
      MarkCutCopyNodes;
      Include(FStates, tsCutPending);
      Invalidate;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DeleteChildren(Node: PVirtualNode; ResetHasChildren: Boolean = False);

// Removes all children and their children from memory without changing the vsHasChildren style by default.

var
  Run,
  Mark: PVirtualNode;
  LastTop,
  LastLeft: Integer;
  ParentVisible: Boolean;

begin
  if Node.ChildCount > 0 then
  begin
    Assert(not (tsIterating in FStates), 'Deleting nodes during tree iteration leads to invalid pointers.');
    
    InterruptValidation;
    LastLeft := FOffsetX;
    LastTop := FOffsetY;

    // Make a local copy of the visibility state of this node to speed up
    // adjusting the visible nodes count.
    ParentVisible := Node = FRoot;
    if not ParentVisible then
      ParentVisible := FullyVisible[Node] and (vsExpanded in Node.States);

    // Indicated that we are clearing the child list, to avoid registering structure change events.
    Include(Node.States, vsClearing);  
    Run := Node.LastChild;
    while Assigned(Run) do
    begin
      if ParentVisible and (vsVisible in Run.States) then
        Dec(FVisibleCount);
        
      Include(Run.States, vsDeleting);
      Mark := Run;
      Run := Run.PrevSibling;
      // Important, to avoid exchange of invalid pointers while disconnecting the node.
      if Assigned(Run) then
        Run.NextSibling := nil;
      DeleteNode(Mark);
    end;
    Exclude(Node.States, vsClearing);
    if ResetHasChildren then
      Exclude(Node.States, vsHasChildren);
    if Node <> FRoot then
      Exclude(Node.States, vsExpanded);
    Node.ChildCount := 0;
    if (Node = FRoot) or (vsDeleting in Node.States) then
    begin
      Node.TotalHeight := Node.NodeHeight;
      Node.TotalCount := 1;
    end
    else
    begin
      AdjustTotalHeight(Node, Node.NodeHeight);
      AdjustTotalCount(Node, 1);
    end;
    Node.FirstChild := nil;
    Node.LastChild := nil;

    InvalidateCache;
    if FUpdateCount = 0 then
    begin
      ValidateCache;
      UpdateScrollbars(True);
      // invalidate entire tree if it scrolled e.g. to make the last node also the
      // bottom node in the treeview
      if (LastLeft <> FOffsetX) or (LastTop <> FOffsetY) then
        Invalidate;
    end;
    StructureChange(Node, crChildDeleted);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DeleteNode(Node: PVirtualNode);

var
  LastTop,
  LastLeft: Integer;
  Parent: PVirtualNode;

begin
  if Assigned(Node) and (Node <> FRoot) then
  begin
    Assert(not (tsIterating in FStates), 'Deleting nodes during tree iteration leads to invalid pointers.');

    // Determine parent node for structure change notification.
    if Node.Parent = FRoot then
      Parent := nil
    else
      Parent := Node.Parent;

    if not (vsClearing in Node.Parent.States) then
      StructureChange(Parent, crChildDeleted);

    LastLeft := FOffsetX;
    LastTop := FOffsetY;

    if vsSelected in Node.States then
    begin
      if FUpdateCount = 0 then
      begin
        RemoveFromSelection(Node);
        InvalidateToBottom(Parent);
      end
      else
        InternalRemoveFromSelection(Node);
    end;
    
    if tsHint in FStates then
    begin
      Application.CancelHint;
      Exclude(FStates, tsHint);
    end;

    DeleteChildren(Node);
    InternalDisconnectNode(Node, False);
    DoFreeNode(Node);

    InvalidateCache;
    if FUpdateCount = 0 then
    begin
      ValidateCache;
      UpdateScrollbars(True);
      // Invalidate entire tree if it scrolled e.g. to make the last node also the
      // bottom node in the treeview.
      if (LastLeft <> FOffsetX) or (LastTop <> FOffsetY) then
        Invalidate;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.DeleteSelectedNodes;

// Deletes all currently selected nodes (including their child nodes).

var
  Nodes: TNodeArray;
  I: Integer;

begin
  BeginUpdate;
  try
    Nodes := GetSortedSelection(True);
    for I := High(Nodes) downto 0 do
      DeleteNode(Nodes[I]);
  finally
    EndUpdate;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.Dragging: Boolean;

begin
  // Check for both OLE drag'n drop as well as VCL drag'n drop.
  Result := ([tsOLEDragPending, tsOLEDragging] * FStates <> []) or inherited Dragging;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.EditNode(Node: PVirtualNode; Column: Integer): Boolean;

// Application triggered edit event for the given node.
// Returns True if the tree started editing otherwise False.

begin
  Assert(Assigned(Node), 'Node must not be nil.');
  Assert((Column > InvalidColumn) and (Column < FHeader.Columns.Count),
    'Column must be a valid column index (-1 if no header is shown).');

  Result := tsEditing in FStates;
  // If the tree is already editing then we don't disrupt this. 
  if not Result then
  begin
    FocusedNode := Node;
    if Assigned(FFocusedNode) and (Node = FFocusedNode) and CanEdit(FFocusedNode, Column) then
    begin
      FEditColumn := Column;
      if not (vsInitialized in Node.States) then
        InitNode(Node);
      DoEdit;
      Result := tsEditing in FStates;
    end
    else
      Result := False;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.EndEditNode: Boolean;

// Called by the application or the current edit link to finish the edit action.

begin
  if [tsEditing, tsEditPending] * FStates <> [] then
    Result := DoEndEdit
  else
    Result := True;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.EndSynch;

begin
  if FSynchUpdateCount > 0 then
    Dec(FSynchUpdateCount);

  if not (csDestroying in ComponentState) then
  begin
    if FSynchUpdateCount = 0 then
    begin
      Exclude(FStates, tsSynchMode);
      DoUpdating(usEndSynch);
    end
    else
      DoUpdating(usSynch);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.EndUpdate;

var
  NewSize: Integer;

begin
  if FUpdateCount > 0 then
    Dec(FUpdateCount);

  if not (csDestroying in ComponentState) then
  begin
    if (FUpdateCount = 0) and (tsUpdating in FStates) then
    begin
      Exclude(FStates, tsUpdating);

      NewSize := PackArray(FSelection, FSelectionCount);
      if NewSize > -1 then
      begin
        FSelectionCount := NewSize;
        SetLength(FSelection, FSelectionCount);
      end;
      ValidateCache;
      if HandleAllocated then
        UpdateScrollBars(True);

      if tsStructureChangePending in FStates then
        DoStructureChange(FLastStructureChangeNode, FLastStructureChangeReason);
      if tsChangePending in FStates then
        DoChange(FLastChangedNode);

      if toAutoSort in FOptions.FAutoOptions then
        SortTree(FHeader.FSortColumn, FHeader.FSortDirection, True);

      SetUpdateState(False);
      if HandleAllocated then
        Invalidate;
    end;

    if FUpdateCount = 0 then
      DoUpdating(usEnd)
    else
      DoUpdating(usUpdate);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.ExecuteAction(Action: TBasicAction): Boolean;

// Some support for standard actions.

begin
  Result := inherited ExecuteAction(Action);

  if not Result then
  begin
    Result := Action is TEditCut;
    if Result then
      CutToClipboard
    else
    begin
      Result := Action is TEditCopy;
      if Result then
        CopyToClipboard
      else
      begin
        Result := Action is TEditPaste;
        if Result then
          PasteFromClipboard
        {$ifdef COMPILER_5_UP}
          else
          begin
            Result := Action is TEditDelete;
            if Result then
              DeleteSelectedNodes
            else
            begin
              Result := Action is TEditSelectAll;
              if Result then
                SelectAll(False);
            end;
          end;
        {$endif COMPILER_5_UP}
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.FinishCutOrCopy;

// Deletes nodes which are marked as being cutted.

var
  Run: PVirtualNode;

begin
  if tsCutPending in FStates then
  begin
    Run := FRoot.FirstChild;
    while Assigned(Run) do
    begin
      if vsCutOrCopy in Run.States then
        DeleteNode(Run);
      Run := GetNextNoInit(Run);
    end;
    Exclude(FStates, tsCutPending);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.FlushClipboard;

// Used to render the data which is currently on the clipboard (finishes delayed rendering).

begin
  if ClipboardStates * FStates <> [] then
  begin
    Include(FStates, tsClipboardFlushing);
    OleFlushClipboard;
    FStates := FStates - [tsCopyPending, tsCutPending, tsClipboardFlushing];
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.FullCollapse(Node: PVirtualNode = nil);

// This routine collapses all expanded nodes in the subtree given by Node or the whole tree if Node is FRoot or nil.
// Only nodes which are expanded will be collapsed. This excludes uninitialized nodes but nodes marked as visible
// will still be collapsed if they are expanded.

var
  Stop: PVirtualNode;

begin
  if FRoot.TotalCount > 1 then
  begin
    if Node = FRoot then
      Node := nil;

    Include(FStates, tsCollapsing);
    BeginUpdate;
    try
      Stop := Node;
      Node := GetLastVisibleNoInit(Node);

      if Assigned(Node) then
      begin
        repeat
          if [vsHasChildren, vsExpanded] * Node.States = [vsHasChildren, vsExpanded] then
            ToggleNode(Node);
          Node := GetPreviousNoInit(Node);
        until Node = Stop;

        // Collapse the start node too.
        if Assigned(Node) and ([vsHasChildren, vsExpanded] * Node.States = [vsHasChildren, vsExpanded]) then
          ToggleNode(Node);
      end;
    finally
      EndUpdate;
      Exclude(FStates, tsCollapsing);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.FullExpand(Node: PVirtualNode = nil);

// This routine expands all collapsed nodes in the subtree given by Node or the whole tree if Node is FRoot or nil.
// All nodes on the way down are initialized so this procedure might take a long time.
// Since all nodes are validated, the tree cannot make use of optimatizations. Hence it is counter productive and you
// should consider avoiding its use.

var
  Stop: PVirtualNode;

begin
  if FRoot.TotalCount > 1 then
  begin
    Include(FStates, tsExpanding);
    BeginUpdate;
    try
      if Node = nil then
      begin
        Node := FRoot.FirstChild;
        Stop := nil;
      end
      else
      begin
        Stop := Node.NextSibling;
        if Stop = nil then
        begin
          Stop := Node;
          repeat
            Stop := Stop.Parent;
          until (Stop = FRoot) or Assigned(Stop.NextSibling);
          if Stop = FRoot then
            Stop := nil
          else
            Stop := Stop.NextSibling;
        end;
      end;

      // Initialize the start node. Others will be initialized in GetNext.
      if not (vsInitialized in Node.States) then
        InitNode(Node);

      repeat
        if not (vsExpanded in Node.States) then
          ToggleNode(Node);
        Node := GetNext(Node);
      until Node = Stop;
    finally
      EndUpdate;
      Exclude(FStates, tsExpanding);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetControlsAlignment: TAlignment;

begin
  Result := FAlignment;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetDisplayRect(Node: PVirtualNode; Column: Integer; TextOnly: Boolean;
  Unclipped: Boolean = False): TRect;

// Determines the client coordinates the given node covers, depending on scrolling, expand state etc.
// If the given node cannot be found (because one of its parents is collapsed or it is invisible) then an empty
// rectangle is returned.
// If TextOnly is True then only the text bounds are returned, that is, the resulting rectangle's left and right border
// are updated according to bidi mode, alignment and text width of the node.
// If Unclipped is True (which only makes sense if also TextOnly is True) then the calculated text rectangle is
// not clipped if the text does not entirely fit into the text space. This is special handling needed for hints.
// If Column is -1 then the entire client width is used before determining the node's width otherwise the bounds of the
// particular column are used.
// Note: Column must be a valid column and is used independent of whether the header is visible or not.

var
  Temp: PVirtualNode;
  Offset: Cardinal;
  Indent,
  TextWidth: Integer;
  MainColumnHit,
  Ghosted: Boolean;
  CurrentBidiMode: TBidiMode;
  CurrentAlignment: TAlignment;

begin
  Assert(Assigned(Node), 'Node must not be nil.');
  Assert(Node <> FRoot, 'Node must not be the hidden root node.');

  MainColumnHit := (Column + 1) in [0, FHeader.MainColumn + 1];
  if not (vsInitialized in Node.States) then
    InitNode(Node);

  Result := Rect(0, 0, 0, 0);
  
  // Check whether the node is visible (determine indentation level btw.).
  Temp := Node;
  Indent := 0;
  while Temp <> FRoot do
  begin                                                                          
    if not (vsVisible in Temp.States) or not (vsExpanded in Temp.Parent.States) then
      Exit;
    Temp := Temp.Parent;
    if MainColumnHit and (Temp <> FRoot) then
      Inc(Indent, FIndent);
  end;

  // Here we know the node is visible.
  Offset := 0;
  if tsUseCache in FStates then
  begin
    // If we can use the position cache then do a binary search to find a cached node which is as close as possible
    // to the current node. Iterate then through all following and visible nodes and sum up their heights.
    Temp := FindInPositionCache(Node, Offset);
    while Assigned(Temp) and (Temp <> Node) do
    begin
      Inc(Offset, Temp.NodeHeight);
      Temp := GetNextVisibleNoInit(Temp);
    end;
  end
  else
  begin
    // If the cache is not available then go straight through all nodes up to the root and sum up their heights.
    Temp := Node;
    repeat
      Temp := GetPreviousVisibleNoInit(Temp);
      if Temp = nil then
        Break;
      Inc(Offset, Temp.NodeHeight);
    until False;
  end;

  Result := Rect(0, Offset, Max(FRangeX, ClientWidth), Offset + Node.NodeHeight);

  // Limit left and right bounds to the given column (if any) and move bounds according to current scroll state.
  if Column > NoColumn then
  begin
    FHeader.FColumns.GetColumnBounds(Column, Result.Left, Result.Right);
    // The right column border is not part of this cell.
    Dec(Result.Right);
    OffsetRect(Result, 0, FOffsetY);
  end
  else
    OffsetRect(Result, FOffsetX, FOffsetY);

  // Limit left and right bounds further if only the text area is required.
  if TextOnly then
  begin
    // Start with the offset of the text in the column and consider the indentation level too.
    Offset := FMargin + Indent;
    // If the text of a node is involved then we have to consider directionality and alignment too.
    if Column = NoColumn then
    begin
      CurrentBidiMode := BidiMode;
      CurrentAlignment := Alignment;
    end
    else
    begin
      CurrentBidiMode := FHeader.FColumns[Column].BidiMode;
      CurrentAlignment := FHeader.FColumns[Column].Alignment;
    end;

    // Since we need the text width of the node it must be initialized.
    if not (vsInitialized in Node.States) then
      InitNode(Node);
    TextWidth := DoGetNodeWidth(Node, Column);

    if MainColumnHit then
    begin
      if toShowRoot in FOptions.FPaintOptions then
        Inc(Offset, FIndent);
      if (toCheckSupport in FOptions.FMiscOptions) and Assigned(FCheckImages) and (Node.CheckType <> ctNone) then
        Inc(Offset, FCheckImages.Width + 2);
    end;
    // Consider associated images.
    if Assigned(FStateImages) and (GetImageIndex(Node, ikState, Column, Ghosted) > -1) then
      Inc(Offset, FStateImages.Width + 2);
    if Assigned(FImages) and (GetImageIndex(Node, ikNormal, Column, Ghosted) > -1) then
      Inc(Offset, FImages.Width + 2);

    // Offset contains now the distance from the left or right border of the rectangle (depending on bidi mode).
    // Now consider the alignment too and calculate the final result.
    if CurrentBidiMode = bdLeftToRight then
    begin
      Inc(Result.Left, Offset);
      // Left-to-right reading does not need any special adjustment of the alignment.
    end
    else
    begin
      Dec(Result.Right, Offset);

      // Consider bidi mode here. In RTL context does left alignment actually mean right alignment and vice versa.
      ChangeBiDiModeAlignment(CurrentAlignment);
    end;

    if Unclipped then
    begin
      // The caller requested the text coordinates unclipped. This means they must be calculated so as would
      // there be enough space, regardless of column bounds etc.
      // The layout still depends on the available space too, because this determines the position
      // of the unclipped text rectangle.
      if Result.Right - Result.Left < TextWidth then
        if CurrentBidiMode = bdLeftToRight then
          CurrentAlignment := taLeftJustify
        else
          CurrentAlignment := taRightJustify;

      case CurrentAlignment of
        taCenter:
          begin
            Result.Left := (Result.Left + Result.Right - TextWidth) div 2;
            Result.Right := Result.Left + TextWidth;
          end;
        taRightJustify:
          Result.Left := Result.Right - TextWidth;
      else // taLeftJustify
        Result.Right := Result.Left + TextWidth;
      end;
    end
    else
      // Modify rectangle only if the text fits entirely into the given room.
      if Result.Right - Result.Left > TextWidth then
        case CurrentAlignment of
          taCenter:
            begin
              Result.Left := (Result.Left + Result.Right - TextWidth) div 2;
              Result.Right := Result.Left + TextWidth;
            end;
          taRightJustify:
            Result.Left := Result.Right - TextWidth;
        else // taLeftJustify
          Result.Right := Result.Left + TextWidth;
        end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetFirstChild(Node: PVirtualNode): PVirtualNode;

// Returns the first child of the given node. The result node is initialized before exit.

begin
  if (Node = nil) or (Node = FRoot) then
    Result := FRoot.FirstChild
  else
    if vsHasChildren in Node.States then
    begin
      if Node.ChildCount = 0 then
        InitChildren(Node);
      Result := Node.FirstChild;
    end
    else
      Result := nil;

  if Assigned(Result) and not (vsInitialized in Result.States) then
    InitNode(Result);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetFirst: PVirtualNode;

// Returns the first node in the tree.

begin
  Result := FRoot.FirstChild;
  if Assigned(Result) and not (vsInitialized in Result.States) then
    InitNode(Result);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetFirstCutCopy: PVirtualNode;

// Returns the first node in the tree which is currently marked for a clipboard operation.
// See also GetNextCutCopy for comments on initialization.

begin
  Result := GetNextCutCopy(nil);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetFirstInitialized: PVirtualNode;

// Returns the first node which is already initialized.

begin
  Result := FRoot.FirstChild;
  if Assigned(Result) and not (vsInitialized in Result.States) then
    Result := GetNextInitialized(Result);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetFirstNoInit: PVirtualNode;

begin
  Result := FRoot.FirstChild;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetFirstSelected: PVirtualNode;

// Returns the first node in the current selection.

begin
  Result := GetNextSelected(nil);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetFirstVisible: PVirtualNode;

// Returns the first visible node in the tree. If necessary nodes are initialized on demand.

begin
  if vsHasChildren in FRoot.States then
  begin
    Result := FRoot;

    if Result.ChildCount = 0 then
      InitChildren(Result);

    // Child nodes are the first choice if possible.
    if Assigned(Result.FirstChild) then
    begin
      Result := GetFirstChild(Result);

      // If there are no children or the first child is not visible then search the sibling nodes or traverse parents.
      if not (vsVisible in Result.States) then
      begin
        repeat
          // Is there a next sibling?
          if Assigned(Result.NextSibling) then
          begin
            Result := Result.NextSibling;
            // The visible state can be removed during initialization so init the node first.
            if not (vsInitialized in Result.States) then
              InitNode(Result);
            if vsVisible in Result.States then
              Break;
          end
          else
          begin
            // No sibling anymore, so use the parent's next sibling.
            if Result.Parent <> FRoot then
              Result := Result.Parent
            else
            begin
              // There are no further nodes to examine, hence there is no further visible node.
              Result := nil;
              Break;
            end;
          end;
        until False;
      end;
    end
    else
      Result := nil;
  end
  else
    Result := nil;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetFirstVisibleChild(Node: PVirtualNode): PVirtualNode;

// Returns the first visible child node of Node. If necessary nodes are initialized on demand.

begin
  Result := GetFirstChild(Node);
  if Assigned(Result) and not (vsVisible in Result.States) then
    Result := GetNextVisibleSibling(Result);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetFirstVisibleChildNoInit(Node: PVirtualNode): PVirtualNode;

// Returns the first visible child node of Node. 

begin
  if Node = nil then
    Node := FRoot;
  Result := Node.FirstChild;
  if Assigned(Result) and not (vsVisible in Result.States) then
    Result := GetNextVisibleSiblingNoInit(Result);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetFirstVisibleNoInit: PVirtualNode;

// Returns the first visible node in the tree. No initialization is performed.

begin
  if vsHasChildren in FRoot.States then
  begin
    Result := FRoot;

    // Child nodes are the first choice if possible.
    if Assigned(Result.FirstChild) then
    begin
      Result := Result.FirstChild;

      // If there are no children or the first child is not visible then search the sibling nodes or traverse parents.
      if not (vsVisible in Result.States) then
      begin
        repeat
          // Is there a next sibling?
          if Assigned(Result.NextSibling) then
          begin
            Result := Result.NextSibling;
            if vsVisible in Result.States then
              Break;
          end
          else
          begin
            // No sibling anymore, so use the parent's next sibling.
            if Result.Parent <> FRoot then
              Result := Result.Parent
            else
            begin
              // There are no further nodes to examine, hence there is no further visible node.
              Result := nil;
              Break;
            end;
          end;
        until False;
      end;
    end
    else
      Result := nil;
  end
  else
    Result := nil;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.GetHitTestInfoAt(X, Y: Integer; Relative: Boolean; var HitInfo: THitInfo);

// Determines the node that occupies the specified point or nil if there's none. The parameter Relative determines
// whether to consider X and Y as being client coordinates (if True) or as being absolute tree coordinates.
// HitInfo is filled with flags describing the hit further.

var
  ColLeft,
  ColRight: Integer;
  NodeTop: Integer;
  InitialColumn,
  NextColumn: Integer;
  CurrentBidiMode: TBidiMode;
  CurrentAlignment: TAlignment;
  
begin
  HitInfo.HitNode := nil;
  HitInfo.HitPositions := [];
  HitInfo.HitColumn := NoColumn;

  // Convert position into absolute coordinate if necessary.
  if Relative then
  begin
    Inc(X, -FOffsetX);
    Inc(Y, -FOffsetY);
  end;

  // Determine if point lies in the tree area.
  if X < 0 then
    Include(HitInfo.HitPositions, hiToLeft)
  else
    if X > Max(FRangeX, ClientWidth) then
      Include(HitInfo.HitPositions, hiToRight);

  if Y < 0 then
    Include(HitInfo.HitPositions, hiAbove)
  else
    if Y > Max(FRangeY, ClientHeight) then
      Include(HitInfo.HitPositions, hiBelow);

  // If the point is in the tree area then check the nodes.
  if HitInfo.HitPositions = [] then
  begin
    HitInfo.HitNode := GetNodeAt(X, Y, False, NodeTop);
    if HitInfo.HitNode = nil then
      Include(HitInfo.HitPositions, hiNowhere)
    else
    begin
      if FHeader.UseColumns then
      begin
        HitInfo.HitColumn := FHeader.Columns.GetColumnAndBounds(Point(X, Y), ColLeft, ColRight, False);
        // If auto column spanning is enabled then look for the last non empty column.
        if toAutoSpanColumns in FOptions.FAutoOptions then
        begin
          InitialColumn := HitInfo.HitColumn;
          // Search to the left of the hit column for empty columns.
          while (HitInfo.HitColumn > NoColumn) and ColumnIsEmpty(HitInfo.HitNode, HitInfo.HitColumn) do
          begin
            NextColumn := FHeader.FColumns.GetPreviousVisibleColumn(HitInfo.HitColumn);
            if NextColumn = InvalidColumn then
              Break;
            HitInfo.HitColumn := NextColumn;
            Dec(ColLeft, FHeader.FColumns[NextColumn].Width);
          end;
          // Search to the right of the hit column for empty columns.
          repeat
            InitialColumn := FHeader.FColumns.GetNextVisibleColumn(InitialColumn);
            if (InitialColumn = InvalidColumn) or not ColumnIsEmpty(HitInfo.HitNode, InitialColumn) then
              Break;
            Inc(ColRight, FHeader.FColumns[InitialColumn].Width);
          until False;
        end;
        // Make the X position and the right border relative to the start of the column.
        Dec(X, ColLeft);
        Dec(ColRight, ColLeft);
      end
      else
      begin
        HitInfo.HitColumn := NoColumn;
        ColRight := Max(FRangeX, ClientWidth);
      end;
      ColLeft := 0;

      if HitInfo.HitColumn = InvalidColumn then
        Include(HitInfo.HitPositions, hiNowhere)
      else
      begin
        // From now on X is in "column" coordinates (relative to the left column border).
        HitInfo.HitPositions := [hiOnItem];
        if HitInfo.HitColumn = NoColumn then
        begin
          CurrentBidiMode := BidiMode;
          CurrentAlignment := Alignment;
        end
        else
        begin
          CurrentBidiMode := FHeader.FColumns[HitInfo.HitColumn].BidiMode;
          CurrentAlignment := FHeader.FColumns[HitInfo.HitColumn].Alignment;
        end;

        if CurrentBidiMode = bdLeftToRight then
          DetermineHitPositionLTR(HitInfo, X, ColRight, CurrentAlignment)
        else
          DetermineHitPositionRTL(HitInfo, X, ColRight, CurrentAlignment);
      end;
    end; 
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetLast(Node: PVirtualNode = nil): PVirtualNode;

// Returns the very last node in the tree branch given by Node and initializes the nodes all the way down including the
// result. By using Node = nil the very last node in the tree is returned.

var
  Next: PVirtualNode;
  
begin
  Result := GetLastChild(Node);
  while Assigned(Result) do
  begin
    // Test if there is a next last child. If not keep the node from the last run.
    // Otherwise use the next last child.
    Next := GetLastChild(Result);
    if Next = nil then
      Break;
    Result := Next;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetLastInitialized(Node: PVirtualNode): PVirtualNode;

// Returns the very last initialized child node in the tree branch given by Node.

begin
  Result := GetLastNoInit(Node);
  if Assigned(Result) and not (vsInitialized in Result.States) then
    Result := GetPreviousInitialized(Result);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetLastNoInit(Node: PVirtualNode = nil): PVirtualNode;

// Returns the very last node in the tree branch given by Node without initialization.

var
  Next: PVirtualNode;

begin
  Result := GetLastChildNoInit(Node);
  while Assigned(Result) do
  begin
    // Test if there is a next last child. If not keep the node from the last run.
    // Otherwise use the next last child.
    Next := GetLastChildNoInit(Result);
    if Next = nil then
      Break;
    Result := Next;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetLastChild(Node: PVirtualNode): PVirtualNode;

// Determines the last child of the given node and initializes it if there is one. 

begin
  if (Node = nil) or (Node = FRoot) then
    Result := FRoot.LastChild
  else
  begin
    if not (vsInitialized in Node.States) then
      InitNode(Node);
    if vsHasChildren in Node.States then
    begin
      if Node.ChildCount = 0 then
        InitChildren(Node);
      Result := Node.LastChild;
    end
    else
      Result := nil;
  end;
  
  if Assigned(Result) and not (vsInitialized in Result.States) then
    InitNode(Result);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetLastChildNoInit(Node: PVirtualNode): PVirtualNode;

// Determines the last child of the given node but does not initialize it. 

begin
  if (Node = nil) or (Node = FRoot) then
    Result := FRoot.LastChild
  else
  begin
    if vsHasChildren in Node.States then
      Result := Node.LastChild
    else
      Result := nil;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetLastVisible(Node: PVirtualNode = nil): PVirtualNode;

// Returns the very last visible node in the tree and initializes nodes all the way down including the result node.

var
  Next: PVirtualNode;
  
begin
  Result := GetLastVisibleChild(Node);
  while Assigned(Result) do
  begin
    // Test if there is a next last visible child. If not keep the node from the last run.
    // Otherwise use the next last visible child.
    Next := GetLastVisibleChild(Result);
    if Next = nil then
      Break;
    Result := Next;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetLastVisibleChild(Node: PVirtualNode): PVirtualNode;

// Determines the last visible child of the given node and initializes it if necessary.

begin
  if (Node = nil) or (Node = FRoot) then
    Result := GetLastChild(FRoot)
  else
    if FullyVisible[Node] and (vsExpanded in Node.States) then
      Result := GetLastChild(Node)
    else
      Result := nil;

  if Assigned(Result) and not (vsVisible in Result.States) then
    Result := GetPreviousVisibleSibling(Result);

  if Assigned(Result) and not (vsInitialized in Result.States) then
    InitNode(Result);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetLastVisibleChildNoInit(Node: PVirtualNode): PVirtualNode;

// Determines the last visible child of the given node without initialization.

begin
  if (Node = nil) or (Node = FRoot) then
    Result := GetLastChildNoInit(FRoot)
  else
    if FullyVisible[Node] and (vsExpanded in Node.States) then
      Result := GetLastChildNoInit(Node)
    else
      Result := nil;

  if Assigned(Result) and not (vsVisible in Result.States) then
    Result := GetPreviousVisibleSiblingNoInit(Result);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetLastVisibleNoInit(Node: PVirtualNode = nil): PVirtualNode;

// Returns the very last visible node in the tree without initialization.

var
  Next: PVirtualNode;

begin
  Result := GetLastVisibleChildNoInit(Node);
  while Assigned(Result) do
  begin
    // Test if there is a next last visible child. If not keep the node from the last run.
    // Otherwise use the next last visible child.
    Next := GetLastVisibleChildNoInit(Result);
    if Next = nil then
      Break;
    Result := Next;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetMaxColumnWidth(Column: Integer): Integer;

// This method determines the width of the largest node in the given column.
// Note: Every visible node in the tree will be initialized contradicting so the virtual paradigm.

var
  Run,
  NextNode: PVirtualNode;
  NodeLeft,
  TextLeft,
  CurrentWidth: Integer;
  WithCheck,
  WithImages,
  WithStateImages,
  Ghosted: Boolean;
  CheckOffset,
  ImageOffset,
  StateImageOffset: Integer;

begin
  Result := 0;

  // Don't check the event here as descentant trees might have overriden the DoGetImageIndex method.
  WithImages := Assigned(FImages);
  if WithImages then
    ImageOffset := FImages.Width + 2
  else
    ImageOffset := 0;
  WithStateImages := Assigned(FStateImages);
  if WithStateImages then
    StateImageOffset := FStateImages.Width + 2
  else
    StateImageOffset := 0;
  if Assigned(FCheckImages) then
    CheckOffset := FCheckImages.Width + 2
  else
    CheckOffset := 0;

  Run := GetFirstVisible;
  if Column = FHeader.MainColumn then
  begin
    if toShowRoot in FOptions.FPaintOptions then
      NodeLeft := Integer((GetNodeLevel(Run) + 1) * FIndent)
    else
      NodeLeft := Integer(GetNodeLevel(Run) * FIndent);

    WithCheck := (toCheckSupport in FOptions.FMiscOptions) and Assigned(FCheckImages);
  end
  else
  begin
    NodeLeft := 0;
    WithCheck := False;
  end;

  // Leave a margin at both sides of the nodes.
  Inc(NodeLeft, 2 * FMargin);

  while Assigned(Run) do
  begin
    TextLeft := NodeLeft;
    if WithCheck and (Run.CheckType <> ctNone) then
      Inc(TextLeft, CheckOffset);
    if WithImages and (GetImageIndex(Run, ikNormal, Column, Ghosted) > -1) then
      Inc(TextLeft, ImageOffset);
    if WithStateImages and (GetImageIndex(Run, ikState, Column, Ghosted) > -1) then
      Inc(TextLeft, StateImageOffset);

    CurrentWidth := DoGetNodeWidth(Run, Column);

    if Result < (TextLeft + CurrentWidth) then
      Result := TextLeft + CurrentWidth;

    // Get next visible node and update left node position if needed.
    NextNode := GetNextVisible(Run);
    if NextNode = nil then
      Break;
    if Column = Header.MainColumn then
      Inc(NodeLeft, CountLevelDifference(Run, NextNode) * Integer(FIndent));
    Run := NextNode;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetNext(Node: PVirtualNode): PVirtualNode;

// Returns next node in tree (advances to next sibling of the node's parent or its parent, if necessary).

begin
  Result := Node;
  if Assigned(Result) then
  begin
    Assert(Result <> FRoot, 'Node must not be the hidden root node.');

    // Has this node got children?
    if vsHasChildren in Result.States then
    begin
      // Yes, there are child nodes. Initialize them if necessary.
      if Result.ChildCount = 0 then
        InitChildren(Result);
    end;

    // if there is no child node try siblings
    if Assigned(Result.FirstChild) then
      Result := Result.FirstChild
    else
    begin
      repeat
        // Is there a next sibling?
        if Assigned(Result.NextSibling) then
        begin
          Result := Result.NextSibling;
          Break;
        end
        else
        begin
          // No sibling anymore, so use the parent's next sibling.
          if Result.Parent <> FRoot then
            Result := Result.Parent
          else
          begin
            // There are no further nodes to examine, hence there is no further visible node.
            Result := nil;
            Break;
          end;
        end;
      until False;
    end;

    if Assigned(Result) and not (vsInitialized in Result.States) then
      InitNode(Result);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetNextCutCopy(Node: PVirtualNode): PVirtualNode;

// Returns the next node in the tree which is currently marked for a clipboard operation. Since only visible nodes can
// be marked (or they are hidden after they have been marked) it is not necessary to initialize nodes to check for
// child nodes. The result, however, is initialized if necessary.

begin
  if ClipboardStates * FStates <> [] then
  begin
    if (Node = nil) or (Node = FRoot) then
      Result := FRoot.FirstChild
    else
      Result := GetNextNoInit(Node);
    while Assigned(Result) and not (vsCutOrCopy in Result.States) do
      Result := GetNextNoInit(Result);
    if Assigned(Result) and not (vsInitialized in Result.States) then
      InitNode(Result);
  end
  else
    Result := nil;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetNextInitialized(Node: PVirtualNode): PVirtualNode;

// Returns the next node in tree which is initialized.

begin
  Result := Node;
  repeat
    Result := GetNextNoInit(Result);
  until (Result = nil) or (vsInitialized in Result.States);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetNextNoInit(Node: PVirtualNode): PVirtualNode;

// optimized variant of GetNext, no initialization of nodes is performed (if a node is not initialized
// then it is considered as not being there)

begin
  Result := Node;
  if Assigned(Result) then
  begin
    Assert(Result <> FRoot, 'Node must not be the hidden root node.');

    // if there is no child node try siblings
    if Assigned(Result.FirstChild) then
      Result := Result.FirstChild
    else
    begin
      repeat
        // Is there a next sibling?
        if Assigned(Result.NextSibling) then
        begin
          Result := Result.NextSibling;
          Break;
        end
        else
        begin
          // No sibling anymore, so use the parent's next sibling.
          if Result.Parent <> FRoot then
            Result := Result.Parent
          else
          begin
            // There are no further nodes to examine, hence there is no further visible node.
            Result := nil;
            Break;
          end;
        end;
      until False;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetNextSelected(Node: PVirtualNode): PVirtualNode;

// Returns the next node in the tree which is currently selected. Since children of unitialized nodes cannot be
// in the current selection (because they simply do not exist yet) it is not necessary to initialize nodes here. 
// The result however is initialized if necessary.

begin
  if FSelectionCount > 0 then
  begin
    if (Node = nil) or (Node = FRoot) then
      Result := FRoot.FirstChild
    else
      Result := GetNextNoInit(Node);
    while Assigned(Result) and not (vsSelected in Result.States) do
      Result := GetNextNoInit(Result);
    if Assigned(Result) and not (vsInitialized in Result.States) then
      InitNode(Result);
  end
  else
    Result := nil;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetNextSibling(Node: PVirtualNode): PVirtualNode;

// Returns the next sibling of Node and initializes it if necessary.

begin
  Result := Node;
  if Assigned(Result) then
  begin
    Assert(Result <> FRoot, 'Node must not be the hidden root node.');

    Result := Node.NextSibling;
    if Assigned(Result) and not (vsInitialized in Result.States) then
      InitNode(Result);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetNextVisible(Node: PVirtualNode): PVirtualNode;

// Returns next node in tree, with regard to Node, which is visible.
// Nodes which need an initialization (including the result) are initialized.

var
  ForceSearch: Boolean;

begin
  Result := Node;
  if Assigned(Result) then
  begin
    Assert(Result <> FRoot, 'Node must not be the hidden root node.');

    // If the given node is not visible then look for a parent node which is visible, otherwise we will
    // likely go unnecessarily through a whole bunch of invisible nodes.
    if not FullyVisible[Result] then
      Result := GetVisibleParent(Result);

    // Has this node got children?
    if [vsHasChildren, vsExpanded] * Result.States = [vsHasChildren, vsExpanded] then
    begin
      // Yes, there are child nodes. Initialize them if necessary.
      if Result.ChildCount = 0 then
        InitChildren(Result);
    end;

    // Child nodes are the first choice if possible.
    if (vsExpanded in Result.States) and Assigned(Result.FirstChild) then
    begin
      Result := GetFirstChild(Result);
      ForceSearch := False;
    end
    else
      ForceSearch := True;

    // If there are no children or the first child is not visible then search the sibling nodes or traverse parents.
    if Assigned(Result) and (ForceSearch or not (vsVisible in Result.States)) then
    begin
      repeat
        // Is there a next sibling?
        if Assigned(Result.NextSibling) then
        begin
          Result := Result.NextSibling;
          if not (vsInitialized in Result.States) then
            InitNode(Result);
          if vsVisible in Result.States then
            Break;
        end
        else
        begin
          // No sibling anymore, so use the parent's next sibling.
          if Result.Parent <> FRoot then
            Result := Result.Parent
          else
          begin
            // There are no further nodes to examine, hence there is no further visible node.
            Result := nil;
            Break;
          end;
        end;
      until False;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetNextVisibleNoInit(Node: PVirtualNode): PVirtualNode;

// Returns the next node in tree, with regard to Node, which is visible.
// No initialization is done.

var
  ForceSearch: Boolean;

begin
  Result := Node;
  if Assigned(Result) then
  begin
    Assert(Result <> FRoot, 'Node must not be the hidden root node.');

    // If the given node is not visible then look for a parent node which is visible, otherwise we will
    // likely go unnecessarily through a whole bunch of invisible nodes.
    if not FullyVisible[Result] then
      Result := GetVisibleParent(Result);

    // Child nodes are the first choice if possible.
    if (vsExpanded in Result.States) and Assigned(Result.FirstChild) then
    begin
      Result := Result.FirstChild;
      ForceSearch := False;
    end
    else
      ForceSearch := True;

    // If there are no children or the first child is not visible then search the sibling nodes or traverse parents.
    if ForceSearch or not (vsVisible in Result.States) then
    begin
      repeat
        // Is there a next sibling?
        if Assigned(Result.NextSibling) then
        begin
          Result := Result.NextSibling;
          if vsVisible in Result.States then
            Break;
        end
        else
        begin
          // No sibling anymore, so use the parent's next sibling.
          if Result.Parent <> FRoot then
            Result := Result.Parent
          else
          begin
            // There are no further nodes to examine, hence there is no further visible node.
            Result := nil;
            Break;
          end;
        end;
      until False;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetNextVisibleSibling(Node: PVirtualNode): PVirtualNode;

// Returns the next visible sibling after Node. Initialization is done implicitly.

begin
  Assert(Assigned(Node) and (Node <> FRoot), 'Invalid parameter.');

  Result := Node;
  repeat
    Result := GetNextSibling(Result);
  until (Result = nil) or (vsVisible in Result.States);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetNextVisibleSiblingNoInit(Node: PVirtualNode): PVirtualNode;

// Returns the next visible sibling after Node.

begin
  Assert(Assigned(Node) and (Node <> FRoot), 'Invalid parameter.');

  Result := Node;
  repeat
    Result := Result.NextSibling;
  until (Result = nil) or (vsVisible in Result.States);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetNodeAt(X, Y: Integer): PVirtualNode;

// Overloaded variant of GetNodeAt to easy life of application developers which do not need to have the exact
// top position returned and always use client coordinates.

var
  Dummy: Integer;

begin
  Result := GetNodeAt(X, Y, True, Dummy);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetNodeAt(X, Y: Integer; Relative: Boolean; var NodeTop: Integer): PVirtualNode;

// This method returns the node that occupies the specified point, or nil if there's none.
// If Releative is True then X and Y are given in client coordinates otherwise they are considered as being
// absolute values into the virtual tree image (regardless of the current offsets in the tree window).
// NodeTop gets the absolute or relative top position of the node returned or is untouched if no node
// could be found.

var
  AbsolutePos,
  CurrentPos: Cardinal;

begin
  if Y < 0 then
    Y := 0;
    
  AbsolutePos := Y;
  if Relative then
    Inc(AbsolutePos, -FOffsetY);

  // CurrentPos tracks a running term of the current position to test for.
  // It corresponds always to the top position of the currently considered node.
  CurrentPos := 0;

  // If the cache is available then use it.
  if tsUseCache in FStates then
    Result := FindInPositionCache(AbsolutePos, CurrentPos)
  else
    Result := GetFirstVisibleNoInit;

  // Determine node, of which position and height corresponds to the scroll position most closely.
  while Assigned(Result) and (Result <> FRoot) do
  begin
    if (vsVisible in Result.States) and (AbsolutePos < (CurrentPos + Result.TotalHeight)) then
    begin
      // Found a node which covers the given position. Now go down one level
      // and search its children (if any, otherwise stop looking).
      if (AbsolutePos >= CurrentPos + Result.NodeHeight) and Assigned(Result.FirstChild) and
         (vsExpanded in Result.States) then
      begin
        Inc(CurrentPos, Result.NodeHeight);
        Result := Result.FirstChild;
        Continue;
      end
      else
        Break;
    end
    else
    begin
      // Advance current position to after the current node, if the node is visible.
      if vsVisible in Result.States then
        Inc(CurrentPos, Result.TotalHeight); 
      // Find following node not being a child of the currently considered node (e.g. a sibling or parent).
      repeat
        // Is there a next sibling?
        if Assigned(Result.NextSibling) then
        begin
          Result := Result.NextSibling;
          if vsVisible in Result.States then
            Break;
        end
        else
        begin
          // No sibling anymore, so use the parent's next sibling.
          if Result.Parent <> FRoot then
            Result := Result.Parent
          else
          begin
            // There are no further nodes to examine, hence there is no further visible node.
            Result := nil;
            Break;
          end;
        end;
      until False;
    end;
  end;

  if Result = FRoot then
    Result := nil;

  // Since the given vertical position is likely not the same as the top position
  // of the found node this top position is returned.
  if Assigned(Result) then
  begin
    NodeTop := CurrentPos;
    if Relative then
      Inc(NodeTop, FOffsetY);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetNodeData(Node: PVirtualNode): Pointer;

// Returns the address of the user defined data area in the node.

begin
  Assert(FNodeDataSize > 0, 'NodeDataSize not initialized.');
  
  if (FNodeDataSize <= 0) or (Node = nil) or (Node = FRoot) then
    Result := nil
  else
    Result := PChar(@Node.Data) + FTotalInternalDataSize;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetNodeLevel(Node: PVirtualNode): Cardinal;

// returns the level of the given node

var
  Run: PVirtualNode;
  
begin
  Result := 0;
  if Assigned(Node) and (Node <> FRoot) then
  begin
    Run := Node.Parent;
    while Run <> FRoot do
    begin
      Run := Run.Parent;
      Inc(Result);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetPrevious(Node: PVirtualNode): PVirtualNode;

// Resturns previous node in tree with regard to Node. The result node is initialized if necessary. 

begin
  Result := Node;
  if Assigned(Result) then
  begin
    Assert(vsInitialized in Result.States, 'Node must already be initialized.');
    Assert(Result <> FRoot, 'Node must not be the hidden root node.');

    // Is there a previous sibling?
    if Assigned(Node.PrevSibling) then
    begin
      // Go down and find the last child node.
      Result := GetLast(Node.PrevSibling);
      if Result = nil then
        Result := Node.PrevSibling;
    end
    else
      // no previous sibling so the parent of the node is the previous visible node
      if Node.Parent <> FRoot then
        Result := Node.Parent
      else
        Result := nil;

    if Assigned(Result) and not (vsInitialized in Result.States) then
      InitNode(Result);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetPreviousInitialized(Node: PVirtualNode): PVirtualNode;

// Returns the previous node in tree which is initialized.

begin
  Result := Node;
  repeat
    Result := GetPreviousNoInit(Result);
  until (Result = nil) or (vsInitialized in Result.States);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetPreviousNoInit(Node: PVirtualNode): PVirtualNode;

// Returns the previous node in the tree with regard to Node. No initialization in done, hence this
// method might be faster than GetPrevious. Not yet initialized nodes are ignored during search.

begin
  Result := Node;
  if Assigned(Result) then
  begin
    Assert(Result <> FRoot, 'Node must not be the hidden root node.');

    // Is there a previous sibling?
    if Assigned(Node.PrevSibling) then
    begin
      // Go down and find the last child node.
      Result := GetLastNoInit(Node.PrevSibling);
      if Result = nil then
        Result := Node.PrevSibling;
    end
    else
      // No previous sibling so the parent of the node is the previous node.
      if Node.Parent <> FRoot then
        Result := Node.Parent
      else
        Result := nil
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetPreviousSibling(Node: PVirtualNode): PVirtualNode;

// get next sibling of Node, initialize it if necessary

begin
  if Assigned(Node) and (Node <> FRoot) then
  begin
    Result := Node.PrevSibling;
    if Assigned(Result) and not (vsInitialized in Result.States) then
      InitNode(Result);
  end
  else
    Result := nil;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetPreviousVisible(Node: PVirtualNode): PVirtualNode;

// Returns the previous node in tree, with regard to Node, which is visible.
// Nodes which need an initialization (including the result) are initialized.

var
  Marker: PVirtualNode;

begin
  Result := Node;
  if Assigned(Result) then
  begin
    Assert(vsInitialized in Result.States, 'Node must already be initialized.');
    Assert(Result <> FRoot, 'Node must not be the hidden root node.');

    // If the given node is not visible then look for a parent node which is visible and use its last visible
    // child or the parent node (if there is no visible child) as result.
    if not FullyVisible[Result] then
    begin
      Result := GetVisibleParent(Result);
      if Result = FRoot then
        Result := nil;
      Marker := GetLastVisible(Result);
      if Assigned(Marker) then
        Result := Marker;
    end
    else
    begin
      repeat
        // Is there a previous sibling node?
        if Assigned(Result.PrevSibling) then
        begin
          Result := Result.PrevSibling;
          // Initialize the new node and check its visibility.
          if not (vsInitialized in Result.States) then
            InitNode(Result);
          if vsVisible in Result.States then
          begin
            // If there are visible child nodes then use the last one.
            Marker := GetLastVisible(Result);
            if Assigned(Marker) then
              Result := Marker;
            Break;
          end;
        end
        else
        begin
          // No previous sibling there so the parent node is the nearest previous node.
          Result := Result.Parent;
          if Result = FRoot then
            Result := nil;
          Break;
        end;
      until False;
      
      if Assigned(Result) and not (vsInitialized in Result.States) then
        InitNode(Result);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetPreviousVisibleNoInit(Node: PVirtualNode): PVirtualNode;

// Returns the previous node in tree, with regard to Node, which is visible.

var
  Marker: PVirtualNode;

begin
  Result := Node;
  if Assigned(Result) then
  begin
    Assert(Result <> FRoot, 'Node must not be the hidden root node.');

    // If the given node is not visible then look for a parent node which is visible and use its last visible
    // child or the parent node (if there is no visible child) as result.
    if not FullyVisible[Result] then
    begin
      Result := GetVisibleParent(Result);
      if Result = FRoot then
        Result := nil;
      Marker := GetLastVisibleNoInit(Result);
      if Assigned(Marker) then
        Result := Marker;
    end
    else
    begin
      repeat
        // Is there a previous sibling node?
        if Assigned(Result.PrevSibling) then
        begin
          Result := Result.PrevSibling;
          if vsVisible in Result.States then
          begin
            // If there are visible child nodes then use the last one.
            Marker := GetLastVisibleNoInit(Result);
            if Assigned(Marker) then
              Result := Marker;
            Break;
          end;
        end
        else
        begin
          // No previous sibling there so the parent node is the nearest previous node.
          Result := Result.Parent;
          if Result = FRoot then
            Result := nil;
          Break;
        end;
      until False;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetPreviousVisibleSibling(Node: PVirtualNode): PVirtualNode;

// Returns the previous visible sibling before Node. Initialization is done implicitly.

begin
  Assert(Assigned(Node) and (Node <> FRoot), 'Invalid parameter.');

  Result := Node;
  repeat
    Result := GetPreviousSibling(Result);
  until (Result = nil) or (vsVisible in Result.States);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetPreviousVisibleSiblingNoInit(Node: PVirtualNode): PVirtualNode;

// Returns the previous visible sibling before Node. 

begin
  Assert(Assigned(Node) and (Node <> FRoot), 'Invalid parameter.');

  Result := Node;
  repeat
    Result := Result.PrevSibling;
  until (Result = nil) or (vsVisible in Result.States);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetSortedCutCopySet(Resolve: Boolean): TNodeArray;

// Same as GetSortedSelection but with nodes marked as being part in the current cut/copy set (e.g. for clipboard).

var
  Run: PVirtualNode;
  Counter: Cardinal;

  //--------------- local function --------------------------------------------

  procedure IncludeThisNode(Node: PVirtualNode);

  // adds the given node to the result

  var
    Len: Cardinal;

  begin
    Len := Length(Result);
    if Counter = Len then
    begin
      if Len < 100 then
        Len := 100
      else
        Len := Len + Len div 10;
      SetLength(Result, Len);
    end;
    Result[Counter] := Node;
    Inc(Counter);
  end;

  //--------------- end local function ----------------------------------------

begin
  Run := FRoot.FirstChild;
  Counter := 0;
  if Resolve then
  begin
    // Resolving is actually easy: just find the first cutted node in logical order
    // and then never go deeper in level than this node as long as there's a sibling node.
    // Restart the search for a cutted node (at any level) if there are no further siblings.
    while Assigned(Run) do
    begin
      if vsCutOrCopy in Run.States then
      begin
        IncludeThisNode(Run);
        if Assigned(Run.NextSibling) then
          Run := Run.NextSibling
        else
        begin
          // If there are no further siblings then go up one or more levels until a node is
          // found or all nodes have been processed. Although we consider here only initialized
          // nodes we don't need to make any special checks as only initialized nodes can also be selected.
          repeat
            Run := Run.Parent;
          until (Run = FRoot) or Assigned(Run.NextSibling);
          if Run = FRoot then
            Break
          else
            Run := Run.NextSibling;
        end;
      end
      else
        Run := GetNextNoInit(Run);
    end;
  end
  else
    while Assigned(Run) do
    begin
      if vsCutOrCopy in Run.States then
        IncludeThisNode(Run);
      Run := GetNextNoInit(Run);
    end;
    
  // set the resulting array to its real length
  SetLength(Result, Counter);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetSortedSelection(Resolve: Boolean): TNodeArray;

// Returns a list of selected nodes sorted in logical order, that is, as they appear in the tree.
// If Resolve is True then nodes which are children of other selected nodes are not put into the new array.
// This feature is in particuar important when doing drag'n drop as in this case all selected node plus their children
// need to be considered. A selected node which is child (grand child etc.) of another selected node is then
// automatically included and doesn't need to be explicitely mentioned in the returned selection array.
//
// Note: The caller is responsible for freeing the array. Allocation is done here. Usually, though, freeing the array
//       doesn't need additional attention as it is automatically freed by Delphi when it gets out of scope.

var
  Run: PVirtualNode;
  Counter: Cardinal;

begin
  SetLength(Result, FSelectionCount);
  if FSelectionCount > 0 then
  begin
    Run := FRoot.FirstChild;
    Counter := 0;
    if Resolve then
    begin
      // Resolving is actually easy: just find the first selected node in logical order
      // and then never go deeper in level than this node as long as there's a sibling node.
      // Restart the search for a selected node (at any level) if there are no further siblings.
      while Assigned(Run) do
      begin
        if vsSelected in Run.States then
        begin
          Result[Counter] := Run;
          Inc(Counter);
          if Assigned(Run.NextSibling) then
            Run := Run.NextSibling
          else
          begin
            // If there are no further siblings then go up one or more levels until a node is
            // found or all nodes have been processed. Although we consider here only initialized
            // nodes we don't need to make any special checks as only initialized nodes can also be selected.
            repeat
              Run := Run.Parent;
            until (Run = FRoot) or Assigned(Run.NextSibling);
            if Run = FRoot then
              Break
            else
              Run := Run.NextSibling;
          end;
        end
        else
          Run := GetNextNoInit(Run);
      end;
    end
    else
      while Assigned(Run) do
      begin
        if vsSelected in Run.States then
        begin
          Result[Counter] := Run;
          Inc(Counter);
        end;
        Run := GetNextNoInit(Run);
      end;

    // Since we may have skipped some nodes the result array is likely to be smaller than the
    // selection array, hence shorten the result to true length.
    if Integer(Counter) < Length(Result) then
      SetLength(Result, Counter);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetTreeRect: TRect;

// Returns the true size of the tree in pixels. This size is at least ClientHeight x ClientWidth and depends on
// the expand state, header size etc.
// Note: if no columns are used then the width of the tree is determined by the largest node which is currently in the
//       client area. This might however not be the largest node in the entire tree.

begin
  Result := Rect(0, 0, Max(FRangeX, ClientWidth), Max(FRangeY, ClientHeight));
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.GetVisibleParent(Node: PVirtualNode): PVirtualNode;

// Returns the first (nearest) parent node of Node which is visible.
// This method is one of the seldom cases where the hidden root node could be returned.

begin
  Assert(Assigned(Node), 'Node must not be nil.');

  Result := Node;
  while Result <> FRoot do
  begin
    // FRoot is always expanded hence the loop will safely stop there if no other node is expanded
    repeat
      Result := Result.Parent;
    until vsExpanded in Result.States;

    if (Result = FRoot) or FullyVisible[Result] then
      Break;

    // if there is still a collapsed parent node then advance to it and repeat the entire loop
    while (Result <> FRoot) and (vsExpanded in Result.Parent.States) do
      Result := Result.Parent;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.HasAsParent(Node, PotentialParent: PVirtualNode): Boolean;

// Determines whether Node has got PotentialParent as one of its parents.

var
  Run: PVirtualNode;

begin
  Result := Assigned(Node) and Assigned(PotentialParent) and (Node <> PotentialParent);
  if Result then
  begin
    Run := Node;
    while (Run <> FRoot) and (Run <> PotentialParent) do
      Run := Run.Parent;
    Result := Run = PotentialParent;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.InsertNode(Node: PVirtualNode; Mode: TVTNodeAttachMode; UserData: Pointer = nil): PVirtualNode;

// Adds a new node relative to Node. The final position is determined by Mode. 
// UserData can be used to set the first 4 bytes of the user data area to an initial value which can be used
// in OnInitNode and will also cause to trigger the OnFreeNode event (if <> nil) even if the node is not yet
// "officially" initialized.
// InsertNode is a compatibility method and will implicitly validate the given node if the new node
// is to be added as child node. This is however against the virtual paradigm and hence I dissuade from its usage.

var
  NodeData: ^Pointer;

begin
  if Mode <> amNoWhere then
  begin
    CancelEditNode;

    if Node = nil then
      Node := FRoot;
    // we need a new node...
    Result := MakeNewNode;
    // avoid erronous attach modes
    if Node = FRoot then
    begin
      case Mode of
        amInsertBefore:
          Mode := amAddChildFirst;
        amInsertAfter:
          Mode := amAddChildLast;
      end;
    end;

    // Validate given node in case the new node becomes its child.
    if (Mode in [amAddChildFirst, amAddChildLast]) and not (vsInitialized in Node.States) then
      InitNode(Node);
    InternalConnectNode(Result, Node, Self, Mode);

    // Check if there is initial user data and there is also enough user data space allocated.
    if Assigned(UserData) then
      if FNodeDataSize >= 4 then
      begin
        NodeData := Pointer(PChar(@Result.Data) + FTotalInternalDataSize);
        NodeData^ := UserData;                                        
        Include(Result.States, vsInitialUserData);
      end
      else
        ShowError(SCannotSetUserData, hcTFCannotSetUserData);

    if FUpdateCount = 0 then
    begin
      // If auto sort is enabled then sort the node or its parent (depending on the insert mode).
      if (toAutoSort in FOptions.FAutoOptions) and (FHeader.FSortColumn > InvalidColumn) then
        case Mode of
          amInsertBefore,
          amInsertAfter:
            // Here no initialization is necessary because *if* a node has already got children then it
            // must also be initialized.
            // Note: Node can never be FRoot at this point.
            Sort(Node.Parent, FHeader.FSortColumn, FHeader.FSortDirection, True);
          amAddChildFirst,
          amAddChildLast:
            Sort(Node, FHeader.FSortColumn, FHeader.FSortDirection, True);
        end;

      UpdateScrollbars(True);
      if Mode = amInsertBefore then
        InvalidateToBottom(Result)
      else
        InvalidateToBottom(Node);
    end;
    StructureChange(Result, crNodeAdded);
  end
  else
    Result := nil;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.InvalidateChildren(Node: PVirtualNode; Recursive: Boolean);

// Invalidates Node and its immediate children.
// If Recursive is True then all grandchildren are invalidated as well.
// The node itself is initialized if necessary and its child nodes are created (and initialized too if
// Recursive is True).

var
  Run: PVirtualNode;

begin
  if Assigned(Node) then
  begin
    if not (vsInitialized in Node.States) then
      InitNode(Node);
    InvalidateNode(Node);
    if (vsHasChildren in Node.States) and (Node.ChildCount = 0) then
      InitChildren(Node);
    Run := Node.FirstChild;
  end
  else
    Run := FRoot.FirstChild;
    
  while Assigned(Run) do
  begin
    InvalidateNode(Run);
    if Recursive then
      InvalidateChildren(Run, True);
    Run := Run.NextSibling;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.InvalidateColumn(Column: Integer);

// Invalidates the client area part of a column.

var
  R: TRect;

begin
  if (FUpdateCount = 0) and FHeader.Columns.IsValidColumn(Column) then
  begin
    R := ClientRect;
    FHeader.Columns.GetColumnBounds(Column, R.Left, R.Right);
    InvalidateRect(Handle, @R, False);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.InvalidateNode(Node: PVirtualNode): TRect;

// Initiates repaint of the given node and returns the just invalidated rectangle.

begin
  if (FUpdateCount = 0) and HandleAllocated then
  begin
    Result := GetDisplayRect(Node, NoColumn, False);
    InvalidateRect(Handle, @Result, False);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.InvalidateToBottom(Node: PVirtualNode);

// Initiates repaint of client area starting at given node. If this node is not visible or not yet initialized
// then nothing happens.

var
  R: TRect;

begin
  if FUpdateCount = 0 then
  begin
    if (Node = nil) or (Node = FRoot) then
      Invalidate
    else
      if [vsInitialized, vsVisible] * Node.States = [vsInitialized, vsVisible] then
      begin
        R := GetDisplayRect(Node, -1, False);
        if R.Top < ClientHeight then
        begin
          R.Bottom := ClientHeight;
          InvalidateRect(Handle, @R, False);
        end;
      end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.InvertSelection(VisibleOnly: Boolean);

// Inverts the current selection (so nodes which are selected become unselected and vice versa).
// If VisibleOnly is True then only visible nodes are considered.

var
  Run: PVirtualNode;
  NewSize: Integer;
  NextFunction: function(Node: PVirtualNode): PVirtualNode of object;
  TriggerChange: Boolean;

begin
  if toMultiSelect in FOptions.FSelectionOptions then
  begin
    Run := FRoot.FirstChild;
    ClearTempCache;
    if VisibleOnly then
      NextFunction := GetNextVisibleNoInit
    else
      NextFunction := GetNextNoInit;
    while Assigned(Run) do
    begin
      if vsSelected in Run.States then
        InternalRemoveFromSelection(Run)
      else
        InternalCacheNode(Run);
      Run := NextFunction(Run);
    end;

    // do some housekeeping
    // Need to trigger the OnChange event from here if nodes were only deleted but not added.
    TriggerChange := False;
    NewSize := PackArray(FSelection, FSelectionCount);
    if NewSize > -1 then
    begin
      FSelectionCount := NewSize;
      SetLength(FSelection, FSelectionCount);
      TriggerChange := True;
    end;
    if FTempNodeCount > 0 then
    begin
      AddToSelection(FTempNodeCache, FTempNodeCount);
      ClearTempCache;
      TriggerChange := False;
    end;
    Invalidate;
    if TriggerChange then
      Change(nil);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.IsEditing: Boolean;

begin
  Result := tsEditing in FStates;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.IsMouseSelecting: Boolean;

begin
  Result := (tsDrawSelPending in FStates) or (tsDrawSelecting in FStates);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.IterateSubtree(Node: PVirtualNode; Callback: TVTGetNodeProc; Data: Pointer;
  Filter: TVirtualNodeStates = []; DoInit: Boolean = False; ChildNodesOnly: Boolean = False): PVirtualNode;

// Iterates through the all children and grandchildren etc. of Node (or the entire tree if Node = nil)
// and calls for each node the provided callback method (which must not be empty).
// Filter determines which nodes to consider (an empty set denotes all nodes).
// If DoInit is True then nodes which aren't initialized yet will be initialized.
// Note: During execution of the callback the application can set Abort to True. In this case the iteration is stopped
//       and the last accessed node (the one on which the callback set Abort to True) is returned to the caller.
//       Otherwise (no abort) nil is returned.

var
  Stop: PVirtualNode;
  Abort: Boolean;
  GetNextNode: TGetNextNodeProc;
  WasIterating: Boolean;
  
begin
  Assert(Node <> FRoot, 'Node must not be the hidden root node.');

  WasIterating := tsIterating in FStates;
  Include(FStates, tsIterating);
  try
    // prepare function to be used when advancing
    if DoInit then
      GetNextNode := GetNext
    else
      GetNextNode := GetNextNoInit;

    Abort := False;
    if Node = nil then
      Stop := nil
    else
    begin
      if not (vsInitialized in Node.States) and DoInit then
        InitNode(Node);

      // The stopper does not need to be initialized since it is not taken into the enumeration.
      Stop := Node.NextSibling;
      if Stop = nil then
      begin
        Stop := Node;
        repeat
          Stop := Stop.Parent;
        until (Stop = FRoot) or Assigned(Stop.NextSibling);
        if Stop = FRoot then
          Stop := nil
        else
          Stop := Stop.NextSibling;
      end;
    end;

    // Use first node if we start with the root.
    if Node = nil then
      Node := GetFirstNoInit;

    if Assigned(Node) then
    begin
      if not (vsInitialized in Node.States) and DoInit then
        InitNode(Node);

      // Skip given node if only the child nodes are requested.
      if (vsHasChildren in Node.States) and ChildNodesOnly then
        Node := GetNextNode(Node);

      if Filter = [] then
      begin
        // unfiltered loop
        while Assigned(Node) and (Node <> Stop) do
        begin
          Callback(Self, Node, Data, Abort);
          if Abort then
            Break;
          Node := GetNextNode(Node);
        end;
      end
      else
      begin
        // filtered loop
        while Assigned(Node) and (Node <> Stop) do
        begin
          if Node.States * Filter = Filter then
            Callback(Self, Node, Data, Abort);
          if Abort then
            Break;
          Node := GetNextNode(Node)
        end;
      end;
    end;
  
    if Abort then
      Result := Node
    else
      Result := nil;
  finally
    if not WasIterating then
      Exclude(FStates, tsIterating);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.LoadFromFile(const FileName: TFileName);

var
  FileStream: TFileStream;

begin
  FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(FileStream);
  finally
    FileStream.Free;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.LoadFromStream(Stream: TStream);

// Clears the current content of the tree and loads a new structure from the given stream.

var
  ThisID: TMagicID;
  Version,
  Count: Cardinal;
  Node: PVirtualNode;

begin
  Clear;
  // Check first whether this is a stream we can read.
  if Stream.Read(ThisID, SizeOf(TMagicID)) < SizeOf(TMagicID) then
    ShowError(SStreamTooSmall, hcTFStreamTooSmall);

  if (ThisID[0] = MagicID[0]) and (ThisID[1] = MagicID[1]) and (ThisID[2] = MagicID[2]) and
    (ThisID[5] = MagicID[5]) then
  begin
    Version := Word(ThisID[3]);
    if Version <= VTTreeStreamVersion then
    begin
      BeginUpdate;
      try
        if Version < 2 then
          Count := MaxInt
        else
          Stream.ReadBuffer(Count, SizeOf(Count));

        while (Stream.Position < Stream.Size) and (Count > 0) do
        begin
          Dec(Count);
          Node := MakeNewNode;
          InternalConnectNode(Node, FRoot, Self, amAddChildLast);
          InternalAddFromStream(Stream, Version, Node);
        end;
        DoNodeCopied(nil);
      finally
        EndUpdate;
      end;
    end
    else
      ShowError(SWrongStreamVersion, hcTFWrongStreamVersion);
  end
  else
    ShowError(SWrongStreamFormat, hcTFWrongStreamFormat);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.MoveTo(Node: PVirtualNode; Tree: TBaseVirtualTree; Mode: TVTNodeAttachMode;
  ChildrenOnly: Boolean);

// A simplified method to allow to move nodes to the root of another tree.

begin
  MoveTo(Node, Tree.FRoot, Mode, ChildrenOnly);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.MoveTo(Source, Target: PVirtualNode; Mode: TVTNodeAttachMode; ChildrenOnly: Boolean);

// Moves the given node (and all its children) to Target. Source must belong to the tree instance which calls this
// MoveTo method. Mode determines how to connect Source to Target.
// This method might involve a change of the tree if Target belongs to a different tree than Source. 

var
  TargetTree: TBaseVirtualTree;
  Allowed: Boolean;
  NewNode: PVirtualNode;
  Stream: TMemoryStream;

begin
  Assert(TreeFromNode(Source) = Self, 'The source tree must contain the source node.');

  if (Mode <> amNoWhere) and Assigned(Source) and (Source <> FRoot) and (Source <> Target) then
  begin
    // assume that an empty destination means the root in this (the source) tree
    if Target = nil then
    begin
      TargetTree := Self;
      Target := FRoot;
      Mode := amAddChildFirst;
    end
    else
      TargetTree := TreeFromNode(Target);

    if Target = TargetTree.FRoot then
    begin
      case Mode of
        amInsertBefore:
          Mode := amAddChildFirst;
        amInsertAfter:
          Mode := amAddChildLast;
      end;
    end;

    if TargetTree = Self then
    begin
      // simple case: move node(s) within the same tree
      if Target = FRoot then
        Allowed := DoNodeMoving(Source, nil)
      else
        Allowed := DoNodeMoving(Source, Target);
      if Allowed then
      begin
        // Check first that Source is not added as new child to a target node which
        // is already a child of Source.
        if HasAsParent(Target, Source) then
          ShowError(SWrongMoveError, hcTFWrongMoveError);

        if not ChildrenOnly then
        begin
          // Disconnect from old location.
          InternalDisconnectNode(Source, True);
          // Connect to new location.
          InternalConnectNode(Source, Target, Self, Mode);
          DoNodeMoved(Source);
        end
        else
        begin
          // Only child nodes should be moved.
          Source := Source.FirstChild;
          while Assigned(Source) do
          begin
            NewNode := Source.NextSibling;
            // Disconnect from old location.
            InternalDisconnectNode(Source, True);
            // Connect to new location.
            InternalConnectNode(Source, Target, Self, Mode);
            DoNodeMoved(Source);
            Source := NewNode;
          end;
        end;
      end;
    end
    else
    begin
      // Difficult case: move node(s) to another tree.
      // In opposition to node copying we ask only once if moving is allowed because
      // we cannot take back a move once done.
      if Target = TargetTree.FRoot then
        Allowed := DoNodeMoving(Source, nil)
      else
        Allowed := DoNodeMoving(Source, Target);
        
      if Allowed then
      begin
        Stream := TMemoryStream.Create;
        try
          // Write all nodes into a temporary stream depending on the ChildrenOnly flag.
          if not ChildrenOnly then
            WriteNode(Stream, Source)
          else
          begin
            Source := Source.FirstChild;
            while Assigned(Source) do
            begin
              WriteNode(Stream, Source);
              Source := Source.NextSibling;
            end;
          end;
          // Now load the serialized nodes into the target node (tree).
          TargetTree.BeginUpdate;
          try
            Stream.Position := 0;
            while Stream.Position < Stream.Size do
            begin
              NewNode := MakeNewNode;
              InternalConnectNode(NewNode, Target, TargetTree, Mode);
              TargetTree.InternalAddFromStream(Stream, VTTreeStreamVersion, NewNode);
              DoNodeMoved(NewNode);
            end;
          finally
            TargetTree.EndUpdate;
          end;
        finally
          Stream.Free;
        end;
        // finally delete original nodes
        BeginUpdate;
        try
          if ChildrenOnly then
            DeleteChildren(Source)
          else
            DeleteNode(Source);
        finally
          EndUpdate;
        end;
      end;
    end;

    InvalidateCache;
    if (FUpdateCount = 0) and Allowed then
    begin
      ValidateCache;
      UpdateScrollBars(True);
      Invalidate;
      if TargetTree <> Self then
        TargetTree.Invalidate;
    end;
    StructureChange(Source, crNodeMoved);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.PasteFromClipboard: Boolean;

// Reads what is currently on the clipboard into the tree (if the format is supported).
// Note: If the application wants to have text or special formats to be inserted then it must implement
//       its own code (OLE). Here only the native tree format is accepted.

var
  Data: IDataObject;
  Source: TBaseVirtualTree;

begin
  Result := False;
  if OleGetClipboard(Data) <> S_OK then
    ShowError(SClipboardFailed, hcTFClipboardFailed)
  else
  try
    // Try to get the source tree of the operation to optimize the operation.
    Source := GetTreeFromDataObject(Data);
    Result := ProcessOLEData(Source, Data, FFocusedNode, FDefaultPasteMode, Assigned(Source) and
      (tsCutPending in Source.FStates));
    if Assigned(Source) and (Source <> Self) then
      Source.FinishCutOrCopy;
  finally
    Data := nil;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.PrepareDragImage(Hotspot: TPoint; const DataObject: IDataObject);

// Initiates an image drag operation. Hotspot is the position of the mouse in client coordinates.

var
  PaintOptions: TVTInternalPaintOptions;
  TreeRect,
  PaintRect: TRect;
  LocalSpot,
  ImagePos,
  PaintTarget: TPoint;
  Image: TBitmap;

begin
  if CanShowDragImage then
  begin
    // Determine the drag rectangle which is a square around the hot spot. Operate in virtual tree space.
    LocalSpot := HotSpot;
    Dec(LocalSpot.X, FOffsetX);
    Dec(LocalSpot.Y, FOffsetY);
    TreeRect := Rect(LocalSpot.X - FDragWidth div 2, LocalSpot.Y - FDragHeight div 2, LocalSpot.X + FDragWidth div 2,
      LocalSpot.Y + FDragHeight div 2);

    // Check that we have a valid rectangle.
    with TreeRect do
    begin
      PaintRect := TreeRect;
      if Left < 0 then
      begin
        PaintTarget.X := -Left;
        PaintRect.Left := 0;
      end
      else
        PaintTarget.X := 0;
      if Top < 0 then
      begin
        PaintTarget.Y := -Top;
        PaintRect.Top := 0;
      end
      else
        PaintTarget.Y := 0;
    end;

    Image := TBitmap.Create;
    with Image do
    try
      PixelFormat := pf32Bit;
      Width := TreeRect.Right - TreeRect.Left;
      Height := TreeRect.Bottom - TreeRect.Top;
      // Erase the entire image with the color key value, for the case not everything
      // in the image is covered by the tree image. 
      Canvas.Brush.Color := Color;
      Canvas.FillRect(Rect(0, 0, Width, Height));

      PaintOptions := [poDrawSelection, poSelectedOnly];
      if FDragImageKind = diMainColumnOnly then
        Include(PaintOptions, poMainOnly);
      PaintTree(Image.Canvas, PaintRect, PaintTarget, PaintOptions);

      // Once we have got the drag image we can convert all necessary coordinates into screen space.
      OffsetRect(TreeRect, FOffsetX, FOffsetY);
      ImagePos := ClientToScreen(TreeRect.TopLeft);
      HotSpot := ClientToScreen(HotSpot);

      FDragImage.ColorKey := Color;
      FDragImage.PrepareDrag(Image, ImagePos, HotSpot, DataObject);
    finally
      Image.Free;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.ProcessDrop(DataObject: IDataObject; TargetNode: PVirtualNode; var Effect: Integer;
  Mode: TVTNodeAttachMode): Boolean;

// Recreates the (sub) tree structure serialized into memory and provided by DataObject. The new nodes are attached to
// the passed node or FRoot if TargetNode is nil.
// Returns True on success, i.e. the CF_VIRTUALTREE format is supported by the data object and the structure could be
// recreated, otherwise False.

var
  Source: TBaseVirtualTree;

begin
  Result := False;
  if Mode = amNoWhere then
    Effect := DROPEFFECT_NONE
  else
  begin
    BeginUpdate;
    // try to get the source tree of the operation
    Source := GetTreeFromDataObject(DataObject);
    if Assigned(Source) then
      Source.BeginUpdate;
    try
      try
        // Before adding the new nodes try to optimize the operation if source and target tree reside in
        // the same application and operation is a move.
        if ((Effect and DROPEFFECT_MOVE) <> 0) and Assigned(Source) then
        begin
          // If both copy and move are specified then prefer a copy because this is not destructing.
          Result := ProcessOLEData(Source, DataObject, TargetNode, Mode, (Effect and DROPEFFECT_COPY) = 0);
          // Since we made an optimized move or a copy there's no reason to act further after DoDragging returns.
          Effect := DROPEFFECT_NONE;
        end
        else
          // Act only if move or copy operation is requested.
          if (Effect and (DROPEFFECT_MOVE or DROPEFFECT_COPY)) <> 0 then
            Result := ProcessOLEData(Source, DataObject, TargetNode, Mode, False)
          else
            Result := False;
      except
        Effect := DROPEFFECT_NONE;
      end;
    finally
      if Assigned(Source) then
        Source.EndUpdate;
      EndUpdate;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

type
  // needed to handle OLE global memory objects  
  TOLEMemoryStream = class(TCustomMemoryStream)
  public
    function Write(const Buffer; Count: Integer): Longint; override;
  end;

//----------------------------------------------------------------------------------------------------------------------

function TOLEMemoryStream.Write(const Buffer; Count: Integer): Integer;

begin
  {$ifdef COMPILER_5_UP}
    raise EStreamError.CreateRes(@SCantWriteResourceStreamError);
  {$else}
    raise EStreamError.Create(SCantWriteResourceStreamError);
  {$endif COMPILER_5_UP}
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.ProcessOLEData(Source: TBaseVirtualTree; DataObject: IDataObject; TargetNode: PVirtualNode;
  Mode: TVTNodeAttachMode; Optimized: Boolean): Boolean;

// Recreates the (sub) tree structure serialized into memory and provided by DataObject. The new nodes are attached to
// the passed node or FRoot if TargetNode is nil according to Mode. Optimized can be set to True if the entire operation
// happens within the same process (i.e. sender and receiver of the OLE operation are located in the same process).
// Optimize = True makes only sense if the operation to carry out is a move hence it is also the indication of the
// operation to be done here. Source is the source of the OLE data and only of use (and usually assigned) when
// an OLE operation takes place in the same application.
// Returns True on success, i.e. the CF_VIRTUALTREE format is supported by the data object and the structure could be
// recreated, otherwise False.

var
  Medium: TStgMedium;
  Stream: TStream;
  Data: Pointer;
  Node: PVirtualNode;
  Nodes: TNodeArray;
  I: Integer;
  Res: HRESULT;

begin
  Nodes := nil;
  // check the data format available by the data object
  with StandardOLEFormat do
  begin
    // read best format
    cfFormat := CF_VIRTUALTREE;
  end;
  Result := DataObject.QueryGetData(StandardOLEFormat) = S_OK;
  if Result then
  begin
    BeginUpdate;
    Result := False;
    try
      if TargetNode = nil then
        TargetNode := FRoot;
      if TargetNode = FRoot then
      begin
        case Mode of
          amInsertBefore:
            Mode := amAddChildFirst;
          amInsertAfter:
            Mode := amAddChildLast;
        end;
      end;

      // Optimized means source is known and in the same process so we can access its pointers, which avoids duplicating
      // the data while doing a serialization. Can only be used with cut'n paste and drag'n drop with move effect.
      if Optimized then
      begin
        if tsOLEDragging in Source.FStates then
          Nodes := Source.FDragSelection
        else
          Nodes := Source.GetSortedCutCopySet(True);

        for I := High(Nodes) downto 0 do
          if not HasAsParent(TargetNode, Nodes[I]) then
            Source.MoveTo(Nodes[I], TargetNode, Mode, False);
        Result := True;
      end
      else
      begin
        Res := DataObject.GetData(StandardOLEFormat, Medium);
        if Res = S_OK then
        begin
          case Medium.tymed of
            TYMED_ISTREAM, // IStream interface
            TYMED_HGLOBAL: // global memory block
              begin
                Stream := nil;
                if Medium.tymed = TYMED_ISTREAM then
                  Stream := TOLEStream.Create(IUnknown(Medium.stm) as IStream)
                else
                begin
                  Data := GlobalLock(Medium.hGlobal);
                  if Assigned(Data) then
                  begin
                    // Get the total size of data to retrieve.
                    I := PCardinal(Data)^;
                    Inc(PCardinal(Data));
                    Stream := TOLEMemoryStream.Create;
                    TOLEMemoryStream(Stream).SetPointer(Data, I);
                  end;
                end;

                if Assigned(Stream) then
                try
                  while Stream.Position < Stream.Size do
                  begin
                    Node := MakeNewNode;
                    InternalConnectNode(Node, TargetNode, Self, Mode);
                    InternalAddFromStream(Stream, VTTreeStreamVersion, Node);
                    // This seems a bit strange because of the callback for granting to add the node
                    // which actually comes after the node has been added. The reason is that the node must
                    // contain valid data otherwise I don't see how the application can make a funded decision.
                    if not DoNodeCopying(Node, TargetNode) then
                      DeleteNode(Node)
                    else
                      DoNodeCopied(Node);
                  end;
                  Result := True;
                finally
                  Stream.Free;
                  if Medium.tymed = TYMED_HGLOBAL then
                    GlobalUnlock(Medium.hGlobal);
                end;
              end;
          end;
          ReleaseStgMedium(Medium);
        end;
      end;
    finally
      EndUpdate;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.ReinitChildren(Node: PVirtualNode; Recursive: Boolean);

// Forces all child nodes of Node to be reinitialized.
// If Recursive is True then also the grandchildren are reinitialized.

var
  Run: PVirtualNode;

begin
  if Assigned(Node) then
  begin
    InitChildren(Node);
    Run := Node.FirstChild;
  end
  else
  begin
    InitChildren(FRoot);
    Run := FRoot.FirstChild;
  end;

  while Assigned(Run) do
  begin
    ReinitNode(Run, recursive);
    Run := Run.NextSibling;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.ReinitNode(Node: PVirtualNode; Recursive: Boolean);

// Forces the given node and all its children (if recursive is True) to be initialized again without
// modifying any data in the nodes nor deleting children (unless the application requests a different amount).

begin
  if Assigned(Node) and (Node <> FRoot) then
  begin
    // remove dynamic styles
    Node.States := Node.States - [vsChecking, vsCutOrCopy, vsDeleting];
    InitNode(Node);
  end;

  if Recursive then
    ReinitChildren(Node, True);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.RepaintNode(Node: PVirtualNode);

// Causes an immediate repaint of the given node.

var
  R: Trect;

begin
  if Assigned(Node) and (Node <> FRoot) then
  begin
    R := GetDisplayRect(Node, -1, False);
    RedrawWindow(Handle, @R, 0, RDW_INVALIDATE or RDW_UPDATENOW or RDW_NOERASE or RDW_VALIDATE or RDW_NOCHILDREN);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.ResetNode(Node: PVirtualNode);

// Deletes all children of the given node and marks it as being uninitialized.

begin
  DoCancelEdit;
  if (Node = nil) or (Node = FRoot) then
    Clear
  else
  begin
    DoReset(Node);
    DeleteChildren(Node);
    // Remove initialized and other dynamic styles, keep persistent styles.
    Node.States := Node.States - [vsInitialized, vsChecking, vsCutOrCopy, vsDeleting, vsHasChildren, vsExpanded];
    InvalidateNode(Node);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SaveToFile(const FileName: TFileName);

// Saves the entire content of the tree into a file (see further notes in SaveToStream).

var
  FileStream: TFileStream;

begin
  FileStream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(FileStream);
  finally
    FileStream.Free;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SaveToStream(Stream: TStream; Node: PVirtualNode = nil);  

// Saves Node and all its children to Stream. If Node is nil then all top level nodes will be stored.
// Note: You should be careful about assuming what is actually saved. The problem here is that we are dealing with
//       virtual data. The tree can so not know what it has to save. The only fact we reliably know is the tree's
//       structure. To be flexible for future enhancements as well as unknown content (unknown to the tree class which
//       is saving/loading the stream) a chunk based approach is used here. Every tree class handles only those
//       chunks which are not handled by an anchestor class and are known by the class.
//
// The base tree class saves only the structure of the tree along with application provided data. Descentants may
// optionally add their own chunks to store additional information. See: WriteChunks.

var
  Count: Cardinal;
  
begin
  Stream.Write(MagicID, SizeOf(MagicID));
  if Node = nil then
  begin
    // Keep number of top level nodes for easy restauration.
    Count := FRoot.ChildCount;
    Stream.WriteBuffer(Count, SizeOf(Count));

    // Save entire tree here.
    Node := FRoot.FirstChild;
    while Assigned(Node) do
    begin
      WriteNode(Stream, Node);
      Node := Node.NextSibling;
    end;
  end
  else
  begin
    Count := 1;
    Stream.WriteBuffer(Count, SizeOf(Count));
    WriteNode(Stream, Node);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.ScrollIntoView(Node: PVirtualNode; Center: Boolean; Horizontally: Boolean = False): Boolean;

// Scrolls the tree so that the given node is in the client area and returns True if the tree really has been
// scrolled (e.g. to avoid further updates) else returns False. If extened focus is enabled then the tree will also
// be horizontally scrolled if needed.
// Note: All collapsed parents of the node are expanded.

var
  R: TRect;
  Run: PVirtualNode;
  UseColumns,
  HScrollBarVisible: Boolean;

begin
  Result := False;
  if Assigned(Node) and (Node <> FRoot) then
  begin
    // Make sure all parents of the node are expanded.
    Run := Node.Parent;
    while Run <> FRoot do
    begin
      if not (vsExpanded in Run.States) then
        ToggleNode(Run);
      Run := Run.Parent;
    end;
    UseColumns := FHeader.UseColumns;
    if UseColumns then
      R := GetDisplayRect(Node, FFocusedColumn, True)
    else
      R := GetDisplayRect(Node, NoColumn, True);

    // The returned rectangle can never be empty after the expand code above.
    // 1) scroll vertically
    if R.Top < 0 then
    begin
      if Center then
        SetOffsetY(FOffsetY - R.Top + ClientHeight div 2)
      else
        SetOffsetY(FOffsetY - R.Top);
      Result := True;
    end
    else
      if R.Bottom > ClientHeight then
      begin
        HScrollBarVisible := Integer(FRangeX) > ClientWidth;
        if Center then
          SetOffsetY(FOffsetY - R.Bottom + ClientHeight div 2)
        else
          SetOffsetY(FOffsetY - R.Bottom + ClientHeight);
        // When scrolling up and the horizontal scroll appears because of the operation
        // then we have to move up the node the horizontal scrollbar's height too
        // in order to avoid that the scroll bar hides the node which we wanted to have in view.
        if not UseColumns and not HScrollBarVisible and (Integer(FRangeX) > ClientWidth) then
          SetOffsetY(FOffsetY - GetSystemMetrics(SM_CYHSCROLL));
        Result := True;
      end;

    if Horizontally then
    begin
      // 2) scroll horizontally
      if R.Right > ClientWidth then
      begin
        SetOffsetX(FOffsetX - R.Right + ClientWidth);
        Result := True;
      end
      else
        if R.Left < 0 then
        begin
          SetOffsetX(FOffsetX - R.Left);
          Result := True;
        end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SelectAll(VisibleOnly: Boolean);

// Select all nodes in the tree.
// If VisibleOnly is True then only visible nodes are selected.

var
  Run: PVirtualNode;
  NextFunction: function(Node: PVirtualNode): PVirtualNode of object;

begin
  if toMultiSelect in FOptions.FSelectionOptions then
  begin
    ClearTempCache;
    if VisibleOnly then
    begin
      Run := GetFirstVisible;
      NextFunction := GetNextVisible;
    end
    else
    begin
      Run := GetFirst;
      NextFunction := GetNext;
    end;

    while Assigned(Run) do
    begin
      if not(vsSelected in Run.States) then
        InternalCacheNode(Run);
      Run := NextFunction(Run);
    end;
    if FTempNodeCount > 0 then
      AddToSelection(FTempNodeCache, FTempNodeCount);
    ClearTempCache;
    Invalidate;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.Sort(Node: PVirtualNode; Column: Integer; Direction: TSortDirection; DoInit: Boolean = True);

// Sorts the given node. The application is queried about how to sort via the OnCompareNodes event.
// Column is simply passed to the the compare function so the application can also sort in a particular column.
// In order to free the application from taking care about the sort direction the parameter Direction is used.
// This way the application can always sort in increasing order, while this method reorders nodes according to this flag.

  //--------------- local functions -------------------------------------------

  function MergeAscending(A, B: PVirtualNode): PVirtualNode;

  // Merges A and B (which both must be sorted via Compare) into one list.

  var
    Dummy: TVirtualNode;

  begin
    // This avoids checking for Result = nil in the loops.
    Result := @Dummy;
    while Assigned(A) and Assigned(B) do
    begin
      if DoCompare(A, B, Column) <= 0 then
      begin
        Result.NextSibling := A;
        Result := A;
        A := A.NextSibling;
      end
      else
      begin
        Result.NextSibling := B;
        Result := B;
        B := B.NextSibling;
      end;
    end;

    // Just append the list which is not nil (or set end of result list to nil if both lists are nil).
    if Assigned(A) then
      Result.NextSibling := A
    else
      Result.NextSibling := B;
    // return start of the new merged list
    Result := Dummy.NextSibling;
  end;

  //---------------------------------------------------------------------------

  function MergeDescending(A, B: PVirtualNode): PVirtualNode;

  // Merges A and B (which both must be sorted via Compare) into one list.

  var
    Dummy: TVirtualNode;

  begin
    // this avoids checking for Result = nil in the loops
    Result := @Dummy;
    while Assigned(A) and Assigned(B) do
    begin
      if DoCompare(A, B, Column) >= 0 then
      begin
        Result.NextSibling := A;
        Result := A;
        A := A.NextSibling;
      end
      else
      begin
        Result.NextSibling := B;
        Result := B;
        B := B.NextSibling;
      end;
    end;

    // Just append the list which is not nil (or set end of result list to nil if both lists are nil).
    if Assigned(A) then
      Result.NextSibling := A
    else
      Result.NextSibling := B;
    // Return start of the newly merged list.
    Result := Dummy.NextSibling;
  end;

  //---------------------------------------------------------------------------

  function MergeSortAscending(var Node: PVirtualNode; N: Cardinal): PVirtualNode;

  // Sorts the list of nodes given by Node (which must not be nil).

  var
    A, B: PVirtualNode;

  begin
    if N > 1 then
    begin
      A := MergeSortAscending(Node, N div 2);
      B := MergeSortAscending(Node, (N + 1) div 2);
      Result := MergeAscending(A, B);
    end
    else
    begin
      Result := Node;
      Node := Node.NextSibling;
      Result.NextSibling := nil;
    end;
  end;

  //---------------------------------------------------------------------------

  function MergeSortDescending(var Node: PVirtualNode; N: Cardinal): PVirtualNode;

  // Sorts the list of nodes given by Node (which must not be nil).

  var
    A, B: PVirtualNode;

  begin
    if N > 1 then
    begin
      A := MergeSortDescending(Node, N div 2);
      B := MergeSortDescending(Node, (N + 1) div 2);
      Result := MergeDescending(A, B);
    end
    else
    begin
      Result := Node;
      Node := Node.NextSibling;
      Result.NextSibling := nil;
    end;
  end;

  //--------------- end local functions ---------------------------------------

var
  Run: PVirtualNode;
  Index: Cardinal;
  
begin
  if tsEditPending in FStates then
  begin
    StopTimer(EditTimer);
    Exclude(FStates, tsEditPending);
  end;

  if not (tsEditing in FStates) or DoEndEdit then
  begin
    if Node = nil then
      Node := FRoot;
    if vsHasChildren in Node.States then
    begin
      if (Node.ChildCount = 0) and DoInit then
        InitChildren(Node);
      // Make sure the children are valid, so they can be sorted at all.
      if DoInit and (Node.ChildCount > 1) then
        ValidateChildren(Node, False);
      // Child count might have changed.
      if Node.ChildCount > 1 then
      begin
        // Sort the linked list, check direction flag only once.
        if Direction = sdAscending then
          Node.FirstChild := MergeSortAscending(Node.FirstChild, Node.ChildCount)
        else
          Node.FirstChild := MergeSortDescending(Node.FirstChild, Node.ChildCount);
        // Consolidate the child list finally.
        Run := Node.FirstChild;
        Run.PrevSibling := nil;
        Index := 0;
        repeat
          Run.Index := Index;
          Inc(Index);
          if Run.NextSibling = nil then
            Break;
          Run.NextSibling.PrevSibling := Run;
          Run := Run.NextSibling;
        until False;
        Node.LastChild := Run;

        InvalidateCache;
      end;
      if FUpdateCount = 0 then
      begin
        ValidateCache;
        Invalidate;
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.SortTree(Column: Integer; Direction: TSortDirection; DoInit: Boolean = True);

  //--------------- local function --------------------------------------------

  procedure DoSort(Node: PVirtualNode);

  // Recursively sorts Node and its child nodes.

  var
    Run: PVirtualNode;

  begin
    Sort(Node, Column, Direction, DoInit);

    Run := Node.FirstChild;
    while Assigned(Run) do
    begin
      if DoInit and not (vsInitialized in Run.States) then
        InitNode(Run);
      if vsInitialized in Run.States then
        DoSort(Run);
      Run := Run.NextSibling;
    end;
  end;

  //--------------- end local function ----------------------------------------

begin
  // Instead of wrapping the sort using BeginUpdate/EndUpdate simply the update counter
  // is modified. Otherwise the EndUpdate call will recurse here.
  Inc(FUpdateCount);
  try
    if Column > InvalidColumn then
      DoSort(FRoot);
    InvalidateCache;
  finally
    if FUpdateCount > 0 then
      Dec(FUpdateCount);
    if FUpdateCount = 0 then
    begin
      ValidateCache;
      Invalidate;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.ToggleNode(Node: PVirtualNode);

// Changes a node's expand state to the opposite state.

var
  LastTopNode,
  Child: PVirtualNode;
  NewHeight: Integer;
  NeedUpdate: Boolean;
  ToggleData: TToggleAnimationData;
  
begin
  Assert(Assigned(Node), 'Node must not be nil.');
  NeedUpdate := False;

  // We don't need to switch the expand state if the node is being deleted otherwise some
  // updates (e.g. visible node count) are done twice with disasterous results).
  if not (vsDeleting in Node.States) then
  begin
    // LastTopNode is needed to know when the entire tree scrolled during toggling.
    // It is of course only needed when we also update the display here.
    if FUpdateCount = 0 then
      LastTopNode := GetTopNode
    else
      LastTopNode := nil;

    if vsExpanded in Node.States then
    begin
      if DoCollapsing(Node) then
      begin
        NeedUpdate := True;

        if (FUpdateCount = 0) and (toAnimatedToggle in FOptions.FAnimationOptions) and not (tsCollapsing in FStates) then
        begin
          Application.CancelHint;
          UpdateWindow(Handle);
        
          // animated collapsing
          with ToggleData do
          begin
            Expand := False;
            R := GetDisplayRect(Node, NoColumn, False);
            R.Bottom := ClientHeight;
            Inc(R.Top, Node.NodeHeight);
            Window := Handle;
            DC := GetDC(Handle);
            Self.Brush.Color := Color;
            Brush := Self.Brush.Handle;
            try
              Animate(Min(R.Bottom - R.Top + 1, Node.TotalHeight - Node.NodeHeight), FAnimationDuration, ToggleCallback,
                @ToggleData);
            finally
              ReleaseDC(Window, DC);
            end;
          end;
        end;

        // collapse the node
        AdjustTotalHeight(Node, Node.NodeHeight);
        if FullyVisible[Node] then
          Dec(FVisibleCount, CountVisibleChildren(Node));
        Exclude(Node.States, vsExpanded);
        DoCollapsed(Node);
      end;
    end
    else
      if DoExpanding(Node) then
      begin
        NeedUpdate := True;
        // expand the node, need to adjust the height
        if not (vsInitialized in Node.States) then
          InitNode(Node);
        if (vsHasChildren in Node.States) and (Node.ChildCount = 0) then
          InitChildren(Node);

        // Avoid setting the vsExpanded style if there are no child nodes.
        if Node.ChildCount > 0 then
        begin
          // Iterate through the child nodes without initializing them. We have to determine the entire height.
          NewHeight := 0;
          Child := Node.FirstChild;
          repeat
            if vsVisible in Child.States then
              Inc(NewHeight, Child.TotalHeight);
            Child := Child.NextSibling;
          until Child = nil;

          if FUpdateCount = 0 then
          begin
            ToggleData.R := GetDisplayRect(Node, NoColumn, False);

            // Do animated expanding if enabled and it is not the last visible node to be expanded.
            if (ToggleData.R.Top < ClientHeight) and ([tsPainting, tsExpanding] * FStates = []) and
              (toAnimatedToggle in FOptions.FAnimationOptions) and (GetNextVisibleNoInit(Node) <> nil) then
            begin
              Application.CancelHint;
              UpdateWindow(Handle);
              // animated expanding
              with ToggleData do
              begin
                Inc(R.Top, Node.NodeHeight);
                R.Bottom := ClientHeight;
                Expand := True;
                Window := Handle;
                DC := GetDC(Handle);

                Self.Brush.Color := Color;
                Brush := Self.Brush.Handle;
                try
                  Animate(Min(R.Bottom - R.Top + 1, NewHeight), FAnimationDuration, ToggleCallback, @ToggleData);
                finally
                  ReleaseDC(Window, DC);
                end
              end;
            end;
          end;
        
          Include(Node.States, vsExpanded);
          AdjustTotalHeight(Node, NewHeight, True);
          if FullyVisible[Node] then
            Inc(FVisibleCount, CountVisibleChildren(Node));

          DoExpanded(Node);
        end;
      end;

    if NeedUpdate then
    begin
      InvalidateCache;
      if FUpdateCount = 0 then
        if Node.ChildCount > 0 then
        begin
          ValidateCache;
          UpdateScrollbars(True);
          // Scroll as much child nodes into view as possible if the node has been expanded.
          if (toAutoScrollOnExpand in FOptions.FAutoOptions) and (vsExpanded in Node.States) then
          begin
            if Integer(Node.TotalHeight) <= ClientHeight then
              ScrollIntoView(GetLastChild(Node), False)
            else
              TopNode := Node;
          end;

          // Check for automatically scrolled tree.
          if LastTopNode <> GetTopNode then
            Invalidate
          else
            InvalidateToBottom(Node);
        end
        else
          InvalidateNode(Node);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.UpdateAction(Action: TBasicAction): Boolean;

// Support for standard actions.

begin
  Result := (Action is TEditCut) or (Action is TEditCopy)
    {$ifdef COMPILER_5_UP} or (Action is TEditDelete) {$endif COMPILER_5_UP};

  if Result then
    TAction(Action).Enabled := FSelectionCount > 0
  else
  begin
    Result := Action is TEditPaste;
    if Result then
      TAction(Action).Enabled := True
    else
    begin
      {$ifdef COMPILER_5_UP}
        Result := Action is TEditSelectAll;
        if Result then
          TAction(Action).Enabled := (toMultiSelect in FOptions.FSelectionOptions) and (FVisibleCount > 0)
        else
      {$endif COMPILER_5_UP}
          Result := inherited UpdateAction(Action);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.UpdateHorizontalScrollBar(DoRepaint: Boolean);

var
  ScrollInfo: TScrollInfo;

begin
  if FHeader.UseColumns then
    FRangeX := FHeader.FColumns.TotalWidth
  else
    FRangeX := GetMaxRightExtend;

  if FScrollBarOptions.ScrollBars in [ssHorizontal, ssBoth] then
  begin
    FillChar(ScrollInfo, SizeOf(ScrollInfo), 0);
    ScrollInfo.cbSize := SizeOf(ScrollInfo);
    ScrollInfo.fMask := SIF_ALL;
    {$ifdef UseFlatScrollbars}
      FlatSB_GetScrollInfo(Handle, SB_HORZ, ScrollInfo);
    {$else}
      GetScrollInfo(Handle, SB_HORZ, ScrollInfo);
    {$endif UseFlatScrollbars}

    if (Integer(FRangeX) > ClientWidth) or FScrollBarOptions.AlwaysVisible then
    begin
      {$ifdef UseFlatScrollbars}
        FlatSB_ShowScrollBar(Handle, SB_HORZ, True);
      {$else}
        ShowScrollBar(Handle, SB_HORZ, True);
      {$endif UseFlatScrollbars}
      
      ScrollInfo.nMin := 0;
      ScrollInfo.nMax := FRangeX;
      ScrollInfo.nPos := -FOffsetX;
      ScrollInfo.nPage := Max(0, ClientWidth + 1);

      ScrollInfo.fMask := SIF_ALL or ScrollMasks[FScrollBarOptions.AlwaysVisible];
      {$ifdef UseFlatScrollbars}
        FlatSB_SetScrollInfo(Handle, SB_HORZ, ScrollInfo, DoRepaint);
      {$else}
        SetScrollInfo(Handle, SB_HORZ, ScrollInfo, DoRepaint);
      {$endif UseFlatScrollbars}
    end
    else
    begin
      ScrollInfo.nMin := 0;
      ScrollInfo.nMax := 0;
      ScrollInfo.nPos := 0;
      ScrollInfo.nPage := 0;
      {$ifdef UseFlatScrollbars}
        FlatSB_ShowScrollBar(Handle, SB_HORZ, False);
        FlatSB_SetScrollInfo(Handle, SB_HORZ, ScrollInfo, False);
      {$else}
        ShowScrollBar(Handle, SB_HORZ, False);
        SetScrollInfo(Handle, SB_HORZ, ScrollInfo, False);
      {$endif UseFlatScrollbars}
    end;
      
    // Since the position is automatically changed if it doesn't meet the range
    // we better read the current position back to stay synchronized.
    {$ifdef UseFlatScrollbars}
      SetOffsetX(-FlatSB_GetScrollPos(Handle, SB_HORZ));
    {$else}
      SetOffsetX(-GetScrollPos(Handle, SB_HORZ));
    {$endif UseFlatScrollbars}
  end
  else
  begin
    {$ifdef UseFlatScrollbars}
      FlatSB_ShowScrollBar(Handle, SB_HORZ, False);
    {$else}
      ShowScrollBar(Handle, SB_HORZ, False);
    {$endif UseFlatScrollbars}

    // Reset the current horizontal offset to account for window resize etc.
    SetOffsetX(FOffsetX);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.UpdateScrollBars(DoRepaint: Boolean);

// adjusts scrollbars to reflect current size and paint offset of the tree

begin
  UpdateHorizontalScrollBar(DoRepaint);
  UpdateVerticalScrollBar(DoRepaint);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.UpdateVerticalScrollBar(DoRepaint: Boolean);

var
  ScrollInfo: TScrollInfo;

begin
  // total node height includes the height of the invisble root node
  if FRoot.TotalHeight < FDefaultNodeHeight then
    FRoot.TotalHeight := FDefaultNodeHeight;
  FRangeY := FRoot.TotalHeight - FRoot.NodeHeight;

  if FScrollBarOptions.ScrollBars in [ssVertical, ssBoth] then
  begin
    ScrollInfo.cbSize := SizeOf(ScrollInfo);
    ScrollInfo.fMask := SIF_ALL;
    {$ifdef UseFlatScrollbars}
      FlatSB_GetScrollInfo(Handle, SB_VERT, ScrollInfo);
    {$else}
      GetScrollInfo(Handle, SB_VERT, ScrollInfo);
    {$endif UseFlatScrollbars}

    if (Integer(FRangeY) > ClientHeight) or FScrollBarOptions.AlwaysVisible then
    begin
      {$ifdef UseFlatScrollbars}
        FlatSB_ShowScrollBar(Handle, SB_VERT, True);
      {$else}
        ShowScrollBar(Handle, SB_VERT, True);
      {$endif UseFlatScrollbars}

      ScrollInfo.nMin := 0;
      ScrollInfo.nMax := FRangeY;
      ScrollInfo.nPos := -FOffsetY;
      ScrollInfo.nPage := Max(0, ClientHeight + 1);

      ScrollInfo.fMask := SIF_ALL or ScrollMasks[FScrollBarOptions.AlwaysVisible];
      {$ifdef UseFlatScrollbars}
        FlatSB_SetScrollInfo(Handle, SB_VERT, ScrollInfo, DoRepaint);
      {$else}
        SetScrollInfo(Handle, SB_VERT, ScrollInfo, DoRepaint);
      {$endif UseFlatScrollbars}
    end
    else
    begin
      ScrollInfo.nMin := 0;
      ScrollInfo.nMax := 0;
      ScrollInfo.nPos := 0;
      ScrollInfo.nPage := 0;
      {$ifdef UseFlatScrollbars}
        FlatSB_ShowScrollBar(Handle, SB_VERT, False);
        FlatSB_SetScrollInfo(Handle, SB_VERT, ScrollInfo, False);
      {$else}
        ShowScrollBar(Handle, SB_VERT, False);
        SetScrollInfo(Handle, SB_VERT, ScrollInfo, False);
      {$endif UseFlatScrollbars}
    end;

    // Since the position is automatically changed if it doesn't meet the range
    // we better read the current position back to stay synchronized.
    {$ifdef UseFlatScrollbars}
      SetOffsetY(-FlatSB_GetScrollPos(Handle, SB_VERT));
    {$else}
      SetOffsetY(-GetScrollPos(Handle, SB_VERT));
    {$endif UseFlatScrollBars}
  end
  else
  begin
    {$ifdef UseFlatScrollbars}
      FlatSB_ShowScrollBar(Handle, SB_VERT, False);
    {$else}
      ShowScrollBar(Handle, SB_VERT, False);
    {$endif UseFlatScrollbars}

    // Reset the current vertical offset to account for window resize etc.
    SetOffsetY(FOffsetY);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualTree.UseRightToLeftReading: Boolean;

// The tree can handle right-to-left reading also on non-middle-east systems, so we cannot use the same function as
// it is implemented in TControl.

begin
  Result := BiDiMode <> bdLeftToRight;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.ValidateChildren(Node: PVirtualNode; Recursive: Boolean);

// Ensures that the children of the given node (and all their children, if Recursive is True) are initialized.
// Node must already be initialized

var
  Child: PVirtualNode;

begin
  if Node = nil then
    Node := FRoot;

  if (vsHasChildren in Node.States) and (Node.ChildCount = 0) then
    InitChildren(Node);
  Child := Node.FirstChild;
  while Assigned(Child) do
  begin
    ValidateNode(Child, Recursive);
    Child := Child.NextSibling;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualTree.ValidateNode(Node: PVirtualNode; Recursive: Boolean);

// Ensures that the given node (and all its children, if Recursive is True) are initialized.

var
  Child: PVirtualNode;

begin
  if Node = nil then
    Node := FRoot
  else
    if not (vsInitialized in Node.States) then
      InitNode(Node);

  if Recursive then
  begin
    if (vsHasChildren in Node.States) and (Node.ChildCount = 0) then
      InitChildren(Node);
    Child := Node.FirstChild;
    while Assigned(Child) do
    begin
      ValidateNode(Child, recursive);
      Child := Child.NextSibling;
    end;
  end;
end;

//----------------- TCustomStringTreeOptions ---------------------------------------------------------------------------

constructor TCustomStringTreeOptions.Create(AOwner: TBaseVirtualTree);

begin
  inherited;
  
  FStringOptions := DefaultStringOptions;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomStringTreeOptions.SetStringOptions(const Value: TVTStringOptions);

var
  ChangedOptions: TVTStringOptions;

begin
  if FStringOptions <> Value then
  begin
    // Exclusive ORing to get all entries wich are in either set but not in both.
    ChangedOptions := FStringOptions + Value - (FStringOptions * Value);
    FStringOptions := Value;
    with FOwner do
      if (toShowStaticText in ChangedOptions) and not (csLoading in ComponentState) and HandleAllocated then
        Invalidate;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomStringTreeOptions.AssignTo(Dest: TPersistent);

begin
  if Dest is TCustomStringTreeOptions then
  begin
    with Dest as TCustomStringTreeOptions do
      StringOptions := Self.StringOptions;
  end;

  // Let ancestors assign their options to the destination class.
  inherited;
end;

//----------------- TVTEdit --------------------------------------------------------------------------------------------

// Implementation of a generic node caption editor.

constructor TVTEdit.Create(Link: TStringEditLink);

begin
  inherited Create(nil);
  ShowHint := False;
  ParentShowHint := False;
  FLink := Link;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTEdit.CNCommand(var Message: TWMCommand);

begin
  if Assigned(FLink) and Assigned(FLink.FTree) and (Message.NotifyCode = EN_UPDATE) and
    not (toGridExtensions in FLink.FTree.FOptions.MiscOptions) then
    AutoAdjustSize;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTEdit.WMChar(var Message: TWMChar);

begin
  if not (Message.CharCode in [VK_ESCAPE, VK_TAB]) then
    inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTEdit.WMDestroy(var Message: TWMDestroy);

begin
  // If editing stopped by other means than accept or cancel then we have to do default processing for
  // pending changes.
  if not FLink.FStopping then
    with FLink, FTree do
    begin
      if (toAutoAcceptEditChange in TreeOptions.StringOptions) and Modified then
        DoNewText(FNode, FColumn, FEdit.Caption);
    end;

  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTEdit.WMGetDlgCode(var Message: TWMGetDlgCode);

begin
  inherited;

  Message.Result := Message.Result or DLGC_WANTTAB;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTEdit.WMKeyDown(var Message: TWMKeyDown);

// Handles some control keys. 

begin
  case Message.CharCode of
    // pretend these keycodes were send to the tree
    VK_ESCAPE:
      FLink.FTree.WndProc(TMessage(Message));
    VK_RETURN:
      FLink.FTree.DoEndEdit;
    VK_UP:
      begin
        Message.CharCode := VK_LEFT;
        inherited;
      end;
    VK_DOWN:
      begin
        Message.CharCode := VK_RIGHT;
        inherited;
      end;
  else
    inherited;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTEdit.AutoAdjustSize;

// Changes the size of the edit to accomodate as much as possible of its text within its container window.
// NewChar describes the next character which will be added to the edit's text.

var
  DC: HDC;
  Size: TSize;
  LastFont: THandle;

begin
  // avoid flicker
  SendMessage(Handle, WM_SETREDRAW, 0, 0);

  DC := GetDC(Handle);
  LastFont := SelectObject(DC, Font.Handle);
  try
    // Read needed space for the current text.
    GetTextExtentPoint32(DC, PChar(Text), Length(Text), Size);
    Inc(Size.cx, 2 * FLink.FTree.FTextMargin);

    // Repaint associated node if the edit becomes smaller.
    if Size.cx < Width then
      FLink.FTree.InvalidateNode(FLink.FNode);

    if FLink.FAlignment = taRightJustify then
      FLink.SetBounds(Rect(Left + Width - Size.cx, Top, Left + Width, Top + Height))
    else
      FLink.SetBounds(Rect(Left, Top, Left + Size.cx, Top + Height));
  finally
    SelectObject(DC, LastFont);
    ReleaseDC(Handle, DC);
    SendMessage(Handle, WM_SETREDRAW, 1, 0);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVTEdit.CreateParams(var Params: TCreateParams);

begin
  inherited;

  // Only with multiline style we can use the text formatting rectangle.
  // This does not harm formatting as single line control, as we don't use word wrapping.
  Params.Style := Params.Style or ES_MULTILINE;
  with Params do
  begin
    if tsUseThemes in FLink.FTree.FStates then
    begin
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end
    else
    begin
      Style := Style or WS_BORDER;
      ExStyle := ExStyle and not WS_EX_CLIENTEDGE;
    end;
  end;
end;

//----------------- TStringEditLink ------------------------------------------------------------------------------------

constructor TStringEditLink.Create;

begin
  inherited;
  FEdit := TVTEdit.Create(Self);
  with FEdit do
  begin
    Visible := False;
    BorderStyle := bsSingle;
    AutoSize := False;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

destructor TStringEditLink.Destroy;

begin
  FEdit.Free;
  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

function TStringEditLink.BeginEdit: Boolean;

// Notifies the edit link that editing can start now. Descentants may cancel node edit
// by returning False.

begin
  Result := not FStopping;
  if Result then
  begin
    FEdit.Show;
    FEdit.SelectAll;
    FEdit.SetFocus;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TStringEditLink.CancelEdit: Boolean;

begin
  Result := not FStopping;
  if Result then
  begin
    FStopping := True;
    FEdit.Hide;
    FTree.CancelEditNode;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TStringEditLink.EndEdit: Boolean;

begin
  Result := not FStopping;
  if Result then
  try
    FStopping := True;
    if FEdit.Modified then
      FTree.DoNewText(FNode, FColumn, FEdit.Caption);
    FEdit.Hide;
  except
    FStopping := False;
    raise;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TStringEditLink.GetBounds: TRect;

begin
  Result := FEdit.BoundsRect;
end;

//----------------------------------------------------------------------------------------------------------------------

function TStringEditLink.PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean;

// retrieves the true text bounds from the owner tree

var
  Text: WideString;

begin
  Result := Tree is TCustomVirtualStringTree;
  if Result then
  begin
    FTree := Tree as TCustomVirtualStringTree;
    FNode := Node;
    FColumn := Column;
    // initial size, font and text of the node
    FTree.GetTextInfo(Node, Column, FEdit.Font, FTextBounds, Text);
    FEdit.Font.Color := clBlack;
    FEdit.Caption := Text;
    FEdit.Parent := Tree;

    if Column <= NoColumn then
    begin
      FEdit.BidiMode := FTree.BidiMode;
      FAlignment := FTree.Alignment;
    end
    else
    begin
      FEdit.BidiMode := FTree.Header.Columns[Column].BidiMode;
      FAlignment := FTree.Header.Columns[Column].Alignment;
    end;

    if FEdit.BidiMode <> bdLeftToRight then
      ChangeBidiModeAlignment(FAlignment);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TStringEditLink.ProcessMessage(var Message: TMessage);

begin
  FEdit.WindowProc(Message);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TStringEditLink.SetBounds(R: TRect);

// Sets the outer bounds of the edit control and the actual edit area in the control.

var
  Offset: Integer;
  
begin
  if not FStopping then
  begin
    with R do
    begin
      // Set the edit's bounds but make sure there's a minimum width and the right border does not
      // extend beyond the parent's left/right border.
      if Left < 0 then
        Left := 0;
      if Right - Left < 30 then
      begin
        if FAlignment = taRightJustify then
          Left := Right - 30
        else
          Right := Left + 30;
      end;
      if Right > FTree.ClientWidth then
        Right := FTree.ClientWidth;
      FEdit.BoundsRect := R;

      // The selected text shall exclude the text margins and be centered vertically.
      // We have to take out the two pixel border of the edit control as well as a one pixel "edit border" the
      // control leaves around the (selected) text.
      R := FEdit.ClientRect;
      Offset := 2;
      if tsUseThemes in FTree.FStates then
        Inc(Offset);
      InflateRect(R, -FTree.FTextMargin + Offset, Offset);
      OffsetRect(R, 0, FTextBounds.Top - FEdit.Top);

      SendMessage(FEdit.Handle, EM_SETRECTNP, 0, Integer(@R));
    end;
  end;
end;

//----------------- TCustomVirtualString -------------------------------------------------------------------------------

constructor TCustomVirtualStringTree.Create(AOwner: TComponent);

begin
  inherited;
  
  FDefaultText := 'Node';
  FInternalDataOffset := AllocateInternalDataArea(SizeOf(Cardinal));
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualStringTree.GetRenderStartValues(Source: TVSTTextSourceType; var Node: PVirtualNode;
  var NextNodeProc: TGetNextNodeProc);

begin
  case Source of
    tstInitialized:
      begin
        Node := GetFirstInitialized;
        NextNodeProc := GetNextInitialized;
      end;
    tstSelected:
      begin
        Node := GetFirstSelected;
        NextNodeProc := GetNextSelected;
      end;
    tstCutCopySet:
      begin
        Node := GetFirstCutCopy;
        NextNodeProc := GetNextCutCopy;
      end;
    tstVisible:
      begin
        Node := GetFirstVisible;
        NextNodeProc := GetNextVisible;
      end;
  else // tstAll
    Node := GetFirst;
    NextNodeProc := GetNext;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualStringTree.GetOptions: TCustomStringTreeOptions;

begin
  Result := FOptions as TCustomStringTreeOptions;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualStringTree.GetText(Node: PVirtualNode; Column: Integer): WideString;

begin
  Assert(Assigned(Node), 'Node must not be nil.');

  if not (vsInitialized in Node.States) then
    InitNode(Node);
  Result := FDefaultText;

  DoGetText(Node, Column, ttNormal, Result);
end;

//----------------------------------------------------------------------------------------------------------------------
                                                
procedure TCustomVirtualStringTree.InitializeTextProperties(const Canvas: TCanvas; Node: PVirtualNode; Column: Integer);

// Initializes default values for customization in PaintNormalText.

begin
  Canvas.Font := Font;

  if (toHotTrack in FOptions.FPaintOptions) and (Node = FCurrentHotNode) then
  begin
    Canvas.Font.Style := Canvas.Font.Style + [fsUnderline];
    Canvas.Font.Color := FColors.HotColor;
  end;

  if (Column = FFocusedColumn) or (toFullRowSelect in FOptions.FSelectionOptions) then
  begin
    if Node = FDropTargetNode then
    begin
      if (FLastDropMode = dmOnNode) or (vsSelected in Node.States)then
        Canvas.Font.Color := clHighlightText
      else
        Canvas.Font.Color := Font.Color;
    end
    else
      if vsSelected in Node.States then
      begin
        if Focused or (toPopupMode in FOptions.FPaintOptions) then
          Canvas.Font.Color := clHighlightText
        else
          Canvas.Font.Color := Font.Color;
      end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualStringTree.PaintNormalText(var PaintInfo: TVTPaintInfo; TextOutFlags: Integer;
  Text: WideString);

// This method is responsible for printing the given test to Canvas (under consideration of the given rectangles).
// The text drawn here is considered as the normal text in a node.
// Note: NodeWidth is the actual width of the text to be printed. This does not necessarily correspond to the width of
//       the node rectangle. The clipping rectangle comprises the entire node (including tree lines, buttons etc.).

var
  TripleWidth: Integer;
  R: TRect;
  DrawFormat: Cardinal;
  Size: TSize;

begin
  with PaintInfo do
  begin
    InitializeTextProperties(Canvas, Node, Column);

    FFontChanged := False;
    TripleWidth := FEllipsisWidth;
    DoPaintText(Node, Canvas, Column, ttNormal);
    if FFontChanged then
    begin
      // If the font has been changed then the ellipsis width must be recalculated.
      TripleWidth := 0;
      // Recalculate also the width of the normal text.
      GetTextExtentPoint32W(Canvas.Handle, PWideChar(Text), Length(Text), Size);
      NodeWidth := Size.cx + 2 * FTextMargin;
    end;

    // Disabled node color overrides all other variants.
    if (vsDisabled in Node.States) or not Enabled then
      Canvas.Font.Color := FColors.DisabledColor;

    R := ContentRect;
    InflateRect(R, -FTextMargin, 0);

    DrawFormat := DT_VCENTER or DT_SINGLELINE;
    if BidiMode <> bdLeftToRight then
      DrawFormat := DrawFormat or DT_RTLREADING;
    // Check if the text must be shortend.
    if (Column > -1) and ((NodeWidth - 2 * FTextMargin) > R.Right - R.Left) then
    begin
      Text := DoShortenString(Canvas, Node, Column, Text, R.Right - R.Left, BidiMode <> bdLeftToRight, TripleWidth);
      if Alignment = taRightJustify then
        DrawFormat := DrawFormat or DT_RIGHT
      else
        DrawFormat := DrawFormat or DT_LEFT;
    end
    else
      DrawFormat := DrawFormat or AlignmentToDrawFlag[Alignment];
    SetBkMode(Canvas.Handle, TRANSPARENT);
    DrawTextW(Canvas.Handle, PWideChar(Text), Length(Text), R, DrawFormat, False);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualStringTree.PaintStaticText(const PaintInfo: TVTPaintInfo; TextOutFlags: Integer;
  const Text: WideString);

// This method retrives and draws the static text bound to a particular node.

var
  R: TRect;
  DrawFormat: Cardinal;

begin
  with PaintInfo do
  begin
    Canvas.Font := Font;
    if toFullRowSelect in FOptions.FSelectionOptions then
    begin
      if Node = FDropTargetNode then
      begin
        if (FLastDropMode = dmOnNode) or (vsSelected in Node.States)then
          Canvas.Font.Color := clHighlightText
        else
          Canvas.Font.Color := Font.Color;
      end
      else
        if vsSelected in Node.States then
        begin
          if Focused or (toPopupMode in FOptions.FPaintOptions) then
            Canvas.Font.Color := clHighlightText
          else
            Canvas.Font.Color := Font.Color;
        end;
    end;

    DrawFormat := DT_VCENTER or DT_SINGLELINE;

    DoPaintText(Node, Canvas, Column, ttStatic);

    // Disabled node color overrides all other variants.
    if (vsDisabled in Node.States) or not Enabled then
      Canvas.Font.Color := FColors.DisabledColor;

    R := ContentRect;
    if Alignment = taRightJustify then
      Dec(R.Right, NodeWidth + FTextMargin)
    else
      Inc(R.Left, NodeWidth + FTextMargin);

    SetBkMode(Canvas.Handle, TRANSPARENT);
    DrawTextW(Canvas.Handle, PWideChar(Text), Length(Text), R, DrawFormat, False);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualStringTree.ReadText(Reader: TReader);

begin
  case Reader.NextValue of
    vaLString, vaString:
      SetDefaultText(Reader.ReadString);
  else
    SetDefaultText(Reader.ReadWideString);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualStringTree.SetDefaultText(const Value: WideString);

begin
  if FDefaultText <> Value then
  begin
    FDefaultText := Value;
    if not (csLoading in ComponentState) then
      Invalidate;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualStringTree.SetOptions(const Value: TCustomStringTreeOptions);

begin
  FOptions.Assign(Value);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualStringTree.SetText(Node: PVirtualNode; Column: Integer; const Value: WideString);

begin
  DoNewText(Node, Column, Value);
  InvalidateNode(Node);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualStringTree.WriteText(Writer: TWriter);

begin
  Writer.WriteWideString(FDefaultText);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualStringTree.WMSetFont(var Msg: TWMSetFont);

// Whenever a new font is applied to the tree some default values are determined to avoid frequent
// determination of the same value.

var
  MemDC: HDC;
  Run: PVirtualNode;
  TM: TTextMetric;
  Size: TSize;
  
begin
  inherited;

  MemDC := CreateCompatibleDC(0);
  try
    SelectObject(MemDC, Msg.Font);
    GetTextMetrics(MemDC, TM);
    FTextHeight := TM.tmHeight;

    GetTextExtentPoint32W(MemDC, '...', 3, Size);
    FEllipsisWidth := Size.cx;
  finally
    DeleteDC(MemDC);
  end;

  // Have to reset all node widths.
  Run := FRoot.FirstChild;
  while Assigned(Run) do
  begin
    PInteger(InternalData(Run))^ := 0;
    Run := GetNextNoInit(Run);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualStringTree.AdjustPaintCellRect(var PaintInfo: TVTPaintInfo; var NextNonEmpty: TColumnIndex);

// In the case a node spans several columns (if enabled) we need to determine how many columns.

begin
  if (toAutoSpanColumns in FOptions.FAutoOptions) and FHeader.UseColumns then
    with FHeader.FColumns, PaintInfo do
    begin
      // Start with the directly following column. Even for right-to-left directionality the next column is the first
      // one to the right. This is so because painting of columns is always done from left to right.
      NextNonEmpty := GetNextVisibleColumn(Column);

      // Depending on the current directionality we need to iterate to the right or the left hand side.
      if BidiMode = bdLeftToRight then
      begin
        repeat
          if (NextNonEmpty = InvalidColumn) or not ColumnIsEmpty(Node, NextNonEmpty) or
            (Items[NextNonEmpty].BidiMode <> bdLeftToRight) then
            Break;
          Inc(CellRect.Right, Items[NextNonEmpty].Width);
          NextNonEmpty := GetNextVisibleColumn(NextNonEmpty);
        until False;
      end
      else
      begin
        NextNonEmpty := GetPreviousVisibleColumn(Column);
        repeat
          if (NextNonEmpty = InvalidColumn) or not ColumnIsEmpty(Node, NextNonEmpty) or
            (Items[NextNonEmpty].BidiMode <> BidiMode) then
            Break;
          Dec(CellRect.Left, Items[NextNonEmpty].Width);
          NextNonEmpty := GetPreviousVisibleColumn(NextNonEmpty);
        until False;
      end;
    end
    else
      inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualStringTree.CalculateTextWidth(Canvas: TCanvas; Node: PVirtualNode; Column: Integer;
  Text: WideString): Integer;

// determines the width of the given text

var
  Size: TSize;

begin
  Result := 2 * FTextMargin;
  if Length(Text) > 0 then
  begin
    Canvas.Font := Font;
    DoPaintText(Node, Canvas, Column, ttNormal);

    GetTextExtentPoint32W(Canvas.Handle, PWideChar(Text), Length(Text), Size);
    Inc(Result, Size.cx);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualStringTree.ColumnIsEmpty(Node: PVirtualNode; Column: Integer): Boolean;

// For hit tests it is necessary to consider cases where columns are empty and automatic column spanning is enabled.
// This method simply checks the given column's text and if this is empty then the column is considered as being empty.

begin
  Result := Length(Text[Node, Column]) = 0;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualStringTree.DefineProperties(Filer: TFiler);

begin
  inherited;

  // Delphi still cannot handle wide strings properly while streaming
  Filer.DefineProperty('WideDefaultText', ReadText, WriteText, True);
  Filer.DefineProperty('StringOptions', ReadOldStringOptions, nil, False);
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualStringTree.DoCreateEditor(Node: PVirtualNode; Column: Integer): IVTEditLink;

begin
  Result := inherited DoCreateEditor(Node, Column);
  // Enable generic label editing support if the application does not have own editors.
  if Result = nil then
    Result := TStringEditLink.Create;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualStringTree.DoGetNodeHint(Node: PVirtualNode; Column: Integer): WideString;

begin
  Result := inherited DoGetNodeHint(Node, Column);
  if Assigned(FOnGetHint) then
    FOnGetHint(Self, Node, Column, ttNormal, Result);
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualStringTree.DoGetNodeTooltip(Node: PVirtualNode; Column: Integer): WideString;

begin
  Result := Hint;
  Result := Text[Node, Column];
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualStringTree.DoGetNodeWidth(Node: PVirtualNode; Column: Integer; Canvas: TCanvas = nil): Integer;

// Returns the text width of the given node in pixels.
// Tthis width is stored in the node's data member to increase access speed.

var
  Data: PInteger;
  
begin
  if Canvas = nil then
    Canvas := Self.Canvas;

  if Column = FHeader.MainColumn then
  begin
    // primary column or no columns
    Data := InternalData(Node);
    Result := Data^;
    if Result = 0 then
    begin
      Data^ := CalculateTextWidth(Canvas, Node, Column, Text[Node, Column]);
      Result := Data^;
    end;
  end
  else
    // any other column
    Result := CalculateTextWidth(Canvas, Node, Column, Text[Node, Column]);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualStringTree.DoGetText(Node: PVirtualNode; Column: Integer; TextType: TVSTTextType;
  var Text: WideString);

begin
  if Assigned(FOnGetText) then
    FOnGetText(Self, Node, Column, TextType, Text);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualStringTree.DoNewText(Node: PVirtualNode; Column: Integer; Text: WideString);

begin
  if Assigned(FOnNewText) then
    FOnNewText(Self, Node, Column, Text);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualStringTree.DoPaintNode(var PaintInfo: TVTPaintInfo);

// Main output routine to print the text of the given node using the space provided in PaintInfo.ContentRect.

var
  S: WideString;
  TextOutFlags: Integer;

begin
  // Set a new OnChange event for the canvas' font so we know if the application changes it in the callbacks.
  // This long winded procedure is necessary because font changes (as well as brush and pen changes) are
  // unfortunately not announced via the Canvas.OnChange event.
  RedirectFontChangeEvent(PaintInfo.Canvas);

  // Determine main text direction as well as other text properties.
  TextOutFlags := ETO_CLIPPED or RTLFlag[PaintInfo.BidiMode <> bdLeftToRight];
  S := Text[PaintInfo.Node, PaintInfo.Column];

  // Paint the normal text first...
  if Length(S) > 0 then
    PaintNormalText(PaintInfo, TextOutFlags, S);

  // ... and afterwards the static text if not centered.
  if (Alignment <> taCenter) and (toShowStaticText in TreeOptions.FStringOptions) then
  begin
    S := '';
    with PaintInfo do
      DoGetText(Node, Column, ttStatic, S);
    if Length(S) > 0 then
      PaintStaticText(PaintInfo, TextOutFlags, S);
  end;
  RestoreFontChangeEvent(PaintInfo.Canvas);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualStringTree.DoPaintText(Node: PVirtualNode; const Canvas: TCanvas; Column: Integer;
  TextType: TVSTTextType);

begin
  if Assigned(FOnPaintText) then
    FOnPaintText(Self, Canvas, Node, Column, TextType);
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualStringTree.DoShortenString(Canvas: TCanvas; Node: PVirtualNode; Column: Integer;
  const S: WideString; Width: Integer; RightToLeft: Boolean; EllipsisWidth: Integer = 0): WideString;

var
  Done: Boolean;

begin
  Done := False;
  if Assigned(FOnShortenString) then
    FOnShortenString(Self, Canvas, Node, Column, S, Width, RightToLeft, Result, Done);
  if not Done then
    Result := ShortenString(Canvas.Handle, S, Width, RightToLeft, EllipsisWidth);
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualStringTree.GetOptionsClass: TTreeOptionsClass;

begin
  Result := TCustomStringTreeOptions;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualStringTree.GetTextInfo(Node: PVirtualNode; Column: Integer; const AFont: TFont; var R: TRect;
  var Text: WideString);

// Returns the font, the text and its bounding rectangle to the caller. R is returned as the closest
// bounding rectangle around Text.

var
  NewHeight: Integer;
  TM: TTextMetric;

begin
  // Get default font and initialize the other parameters.
  inherited GetTextInfo(Node, Column, AFont, R, Text);

  Canvas.Font := AFont;

  FFontChanged := False;
  RedirectFontChangeEvent(Canvas);
  DoPaintText(Node, Canvas, Column, ttNormal);
  if FFontChanged then
  begin
    AFont.Assign(Canvas.Font);
    GetTextMetrics(Canvas.Handle, TM);
    NewHeight := TM.tmHeight;
  end
  else // Otherwise the correct font is already there and we only need to set the correct height.
    NewHeight := FTextHeight;
  RestoreFontChangeEvent(Canvas);

  // Alignment to the actual text.
  Text := Self.Text[Node, Column];
  R := GetDisplayRect(Node, Column, True, True);
  if toShowHorzGridLines in TreeOptions.PaintOptions then
    Dec(R.Bottom);
  InflateRect(R, 0, -(R.Bottom - R.Top - NewHeight) div 2);
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualStringTree.InternalData(Node: PVirtualNode): Pointer;

begin
  if (Node = FRoot) or (Node = nil) then
    Result := nil
  else
    Result := PChar(Node) + FInternalDataOffset;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualStringTree.MainColumnChanged;

var
  Run: PVirtualNode;

begin
  inherited;

  // Have to reset all node widths.
  Run := FRoot.FirstChild;
  while Assigned(Run) do
  begin
    PInteger(InternalData(Run))^ := 0;
    Run := GetNextNoInit(Run);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualStringTree.ReadChunk(Stream: TStream; Version: Integer; Node: PVirtualNode; ChunkType,
  ChunkSize: Integer): Boolean;

// read in the caption chunk if there is one

var
  NewText: WideString;

begin
  case ChunkType of
    CaptionChunk:
      begin
        NewText := '';
        if ChunkSize > 0 then
        begin
          SetLength(NewText, ChunkSize div 2);
          Stream.Read(PWideChar(NewText)^, ChunkSize);
        end;
        // Do a new text event regardless of the caption content to allow removing the default string.
        DoNewText(Node, FHeader.MainColumn, NewText);
        Result := True;
      end;
  else
    Result := inherited ReadChunk(Stream, Version, Node, ChunkType, ChunkSize);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

type
  TOldVTStringOption = (soSaveCaptions, soShowStaticText);

procedure TCustomVirtualStringTree.ReadOldStringOptions(Reader: TReader);

// Migration helper routine to silently convert forms containing the old tree options member into the new
// sub-options structure.

var
  OldOption: TOldVTStringOption;
  EnumName: string;

begin
  // If we are at design time currently then let the designer know we changed something.
  UpdateDesigner;

  // It should never happen at this place that there is something different than the old set.
  if Reader.ReadValue = vaSet then
    with TreeOptions do
    begin
      // Remove all default values set by the constructor.
      StringOptions := [];

      while True do
      begin
        // Sets are stored with their members as simple strings. Read them one by one and map them to the new option
        // in the correct sub-option set.
        EnumName := Reader.ReadStr;
        if EnumName = '' then
          Break;
        OldOption := TOldVTStringOption(GetEnumValue(TypeInfo(TOldVTStringOption), EnumName));
        case OldOption of
          soSaveCaptions:
            StringOptions := FStringOptions + [toSaveCaptions];
          soShowStaticText:
            StringOptions := FStringOptions + [toShowStaticText];
        end;
      end;
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualStringTree.RenderOLEData(const FormatEtcIn: TFormatEtc; out Medium: TStgMedium;
  ForClipboard: Boolean): HResult;

// Returns string expressions of all currently selected nodes in the Medium structure.

begin
  try
    if ForClipboard then
      Medium.hGlobal := ContentToClipboard(FormatEtcIn.cfFormat, tstCutCopySet)
    else
      Medium.hGlobal := ContentToClipboard(FormatEtcIn.cfFormat, tstSelected);

    // Fill rest of the Medium structure if rendering went fine.
    if Medium.hGlobal <> 0 then
    begin
      Medium.tymed := TYMED_HGLOBAL;
      Medium.unkForRelease := nil;

      Result := S_OK;
    end
    else
      Result := inherited RenderOLEData(FormatEtcIn, Medium, ForClipboard);
  except
    Result := E_FAIL;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualStringTree.WriteChunks(Stream: TStream; Node: PVirtualNode);

// Adds another sibling chunk for Node storing the label if the node is initialized.
// Note: If the application stores a node's caption in the node's data member (which will be quite common) and needs to
//       store more node specific data then it should use the OnSaveNode event rather than the caption autosave function
//       (take out soSaveCaption from StringOptions). Otherwise the caption is unnecessarily stored twice.

var
  Header: TChunkHeader;
  S: WideString;
  Len: Integer;

begin
  inherited;
  if (toSaveCaptions in TreeOptions.FStringOptions) and (Node <> FRoot) and
    (vsInitialized in Node.States) then
    with Stream do
    begin
      // Read the node's caption (primary column only).
      S := Text[Node, FHeader.MainColumn];
      Len := 2 * Length(S);
      if Len > 0 then
      begin
        // Write a new sub chunk.
        Header.ChunkType := CaptionChunk;
        Header.ChunkSize := Len;
        Write(Header, SizeOf(Header));
        Write(PWideChar(S)^, Len);
      end;
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualStringTree.ContentToClipboard(Format: Word; Source: TVSTTextSourceType): HGLOBAL;

// This method constructs a shareable memory object filled with string data in the required format. Supported are:
// CF_TEXT - plain ANSI text (Unicode text is converted using the user's current locale)
// CF_UNICODETEXT - plain Unicode text
// CF_CSV - comma separated plain ANSI text 
// CF_VRTF + CF_RTFNOOBS - rich text (plain ANSI)
// CF_HTML - HTML text encoded using UTF-8
//
// Result is the handle to a globally allocated memory block which can directly be used for clipboard and drag'n drop
// transfers. The caller is responsible for freeing the memory. If for some reason the content could not be rendered
// the Result is 0.

  //--------------- local function --------------------------------------------

  procedure MakeFragment(var HTML: string);

  // Helper routine to build a properly-formatted HTML fragment.

  const
    Version = 'Version:1.0'#13#10;
    StartHTML = 'StartHTML:';
    EndHTML = 'EndHTML:';
    StartFragment = 'StartFragment:';
    EndFragment = 'EndFragment:';
    DocType = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">';
    HTMLIntro = '<html><head><META http-equiv=Content-Type content="text/html; charset=utf-8">' +
      '</head><body><!--StartFragment-->';
    HTMLExtro = '<!--EndFragment--></body></html>';
    NumberLengthAndCR = 10;

    // Let the compiler determine the description length.
    DescriptionLength = Length(Version) + Length(StartHTML) + Length(EndHTML) + Length(StartFragment) +
      Length(EndFragment) + 4 * NumberLengthAndCR;

  var
    Description: string;
    StartHTMLIndex,
    EndHTMLIndex,
    StartFragmentIndex,
    EndFragmentIndex: Integer;

  begin
    // The HTML clipboard format is defined by using byte positions in the entire block where HTML text and
    // fragments start and end. These positions are written in a description. Unfortunately the positions depend on the
    // length of the description but the description may change with varying positions.
    // To solve this dilemma the offsets are converted into fixed length strings which makes it possible to know
    // the description length in advance.
    StartHTMLIndex := DescriptionLength;              // position 0 after the description
    StartFragmentIndex := StartHTMLIndex + Length(DocType) + Length(HTMLIntro);
    EndFragmentIndex := StartFragmentIndex + Length(HTML);
    EndHTMLIndex := EndFragmentIndex + Length(HTMLExtro);

    Description := Version +
      SysUtils.Format('%s%.8d', [StartHTML, StartHTMLIndex]) + #13#10 +
      SysUtils.Format('%s%.8d', [EndHTML, EndHTMLIndex]) + #13#10 +
      SysUtils.Format('%s%.8d', [StartFragment, StartFragmentIndex]) + #13#10 +
      SysUtils.Format('%s%.8d', [EndFragment, EndFragmentIndex]) + #13#10;
    HTML := Description + DocType + HTMLIntro + HTML + HTMLExtro;
  end;

  //--------------- end local function ----------------------------------------

var
  Data: Pointer;
  DataSize: Cardinal;
  S: string;
  WS: WideString;
  P: Pointer;

begin
  Result := 0;
  case Format of
    CF_TEXT:
      begin
        S := ContentToText(Source, #9) + #0;
        Data := PChar(S);
        DataSize := Length(S);
      end;
    CF_UNICODETEXT:
      begin
        WS := ContentToUnicode(Source, #9) + #0;
        Data := PWideChar(WS);
        DataSize := 2 * Length(WS);
      end;
  else
    if Format = CF_CSV then
      S := ContentToText(Source, ListSeparator) + #0
    else
      if (Format = CF_VRTF) or (Format = CF_VRTFNOOBJS) then
        S := ContentToRTF(Source) + #0
      else
        if Format = CF_HTML then
        begin
          S := ContentToHTML(Source);
          // Build a valid HTML clipboard fragment.
          MakeFragment(S);
          S := S + #0;
        end;
    Data := PChar(S);
    DataSize := Length(S);
  end;

  if DataSize > 0 then
  begin
    Result := GlobalAlloc(GHND or GMEM_SHARE, DataSize);
    P := GlobalLock(Result);
    Move(Data^, P^, DataSize);
    GlobalUnlock(Result);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualStringTree.ContentToHTML(Source: TVSTTextSourceType; Caption: WideString = ''): string;

// Renders the current tree content (depending on Source) as HTML text encoded in UTF-8.
// If Caption is not empty then it is used to create and fill the header for the table build here.
// Based on ideas and code from Frank van den Bergh and Andreas H�rstemeier.

type
  UCS2 = Word;
  UCS4 = Cardinal;

const
  MaximumUCS4: UCS4 = $7FFFFFFF;
  ReplacementCharacter: UCS4 = $0000FFFD;

var
  Buffer: TBufferedString;
  
  //--------------- local functions -------------------------------------------

  function ConvertSurrogate(S1, S2: UCS2): UCS4;

  // Converts a pair of high and low surrogate into the corresponding UCS4 character.
  
  const
    SurrogateOffset = ($D800 shl 10) + $DC00 - $10000;

  begin
    Result := Word(S1) shl 10 + Word(S2) - SurrogateOffset;
  end;

  //---------------------------------------------------------------------------

  function UTF16ToUTF8(const S: WideString): string;

  // Converts the given Unicode text (which may contain surrogates) into
  // the UTF-8 encoding used for the HTML clipboard format.

  const
    FirstByteMark: array[0..6] of Byte = ($00, $00, $C0, $E0, $F0, $F8, $FC);

  var
    Ch: UCS4;
    I, J, T: Integer;
    BytesToWrite: Cardinal;

  begin
    if Length(S) = 0 then
      Result := ''
    else
    begin
      // Make room for the result. Assume worst case, there are only short texts to convert.
      SetLength(Result, 6 * Length(S));
      T := 1;
      I := 1;
      while I <= Length(S) do
      begin
        Ch := UCS4(S[I]);

        // Is the character a surrogate?
        if (Ch and $FFFFF800) = $D800 then
        begin
          Inc(I);
          // Check the following char whether it forms a valid surrogate pair with the first character.
          if (I <= Length(S)) and ((UCS4(S[I]) and $FFFFFC00) = $DC00) then
            Ch := ConvertSurrogate(UCS2(Ch), UCS2(S[I]))
          else // Skip invalid surrogate value.
            Continue;
        end;

        if Ch < $80 then
          BytesToWrite := 1
        else
          if Ch < $800 then
            BytesToWrite := 2
          else
            if Ch < $10000 then
              BytesToWrite := 3
            else
              if Ch < $200000 then
                BytesToWrite := 4
              else
                if Ch < $4000000 then
                  BytesToWrite := 5
                else
                  if Ch <= MaximumUCS4 then
                    BytesToWrite := 6
                  else
                  begin
                    BytesToWrite := 2;
                    Ch := ReplacementCharacter;
                  end;

        for J := BytesToWrite downto 2 do
        begin
          Result[T + J - 1] := Char((Ch or $80) and $BF);
          Ch := Ch shr 6;
        end;
        Result[T] := Char(Ch or FirstByteMark[BytesToWrite]);
        Inc(T, BytesToWrite);

        Inc(I);
      end;
      SetLength(Result, T - 1); // set to actual length
    end;
  end;
  
  //---------------------------------------------------------------------------

  procedure WriteColorAsHex(Color: TColor);

  var
    WinColor: COLORREF;
    I: Integer;
    Component,
    Value: Byte;

  begin
    Buffer.Add('#');
    WinColor := ColorToRGB(Color);
    I := 1;
    while I <= 6 do
    begin
      Component := WinColor and $FF;

      Value := 48 + (Component shr 4);
      if Value > $39 then
        Inc(Value, 7);
      Buffer.Add(Char(Value));
      Inc(I);

      Value := 48 + (Component and $F);
      if Value > $39 then
        Inc(Value, 7);
      Buffer.Add(Char(Value));
      Inc(I);

      WinColor := WinColor shr 8;
    end;
  end;

  //---------------------------------------------------------------------------

  procedure WriteStyle(Name: string; Font: TFont);

  // Creates a CSS style entry with the given name for the given font.
  // If Name is empty then the entry is created as inline style.

  begin
    if Length(Name) = 0 then
      Buffer.Add(' style="{font:')
    else
    begin
      Buffer.Add('.');
      Buffer.Add(Name);
      Buffer.Add('{font:');
    end;
    if fsUnderline in Font.Style then
      Buffer.Add(' underline');
    if fsItalic in Font.Style then
      Buffer.Add(' italic');
    if fsBold in Font.Style then
      Buffer.Add(' bold');
    Buffer.Add(Format(' %dpt %s;', [Font.Size, Font.Name]));
    Buffer.Add('color:');
    WriteColorAsHex(Font.Color);
    Buffer.Add(';}');
    if Length(Name) = 0 then
      Buffer.Add('"');
  end;

  //--------------- end local functions ---------------------------------------

var
  I, J : Integer;
  Level, MaxLevel: Cardinal;
  AddHeader: string;
  Save, Run: PVirtualNode;
  GetNextNode: TGetNextNodeProc;
  Text: WideString;

  RenderColumns: Boolean;
  Columns: TColumnsArray;
  ColumnColors: array of string;
  Index: Integer;
  Indices: TIndexArray;
  IndentWidth,
  LineStyleText: string;
  Alignment: TAlignment;
  BidiMode: TBidiMode;

  CellPadding: string;

begin
  Buffer := TBufferedString.Create;
  try
    // For customization by the application or descentants we use again the redirected font change event.
    RedirectFontChangeEvent(Canvas);

    CellPadding := Format('padding-left:%dpx;padding-right:%0:dpx;', [FMargin]);

    IndentWidth := IntToStr(FIndent);
    AddHeader := ' ';
    // Add title if adviced so by giving a caption.
    if Length(Caption) > 0 then
      AddHeader := AddHeader + 'caption="' + UTF16ToUTF8(Caption) + '"'; 
    if Borderstyle <> bsNone then
      AddHeader := AddHeader + Format('border="%d" frame=box', [BorderWidth + 1]);

    // Create HTML table based on the tree structure. To simplify formatting we use styles defined in a small CSS area.
    Buffer.Add('<style type="text/css">');
    Buffer.AddnewLine;
    WriteStyle('default', Font);
    Buffer.AddNewLine;
    WriteStyle('header', FHeader.Font);
    Buffer.AddNewLine;

    // Determine grid/table lines and create CSS for it.
    // Vertical and/or horizontal border to show.
    if FLineStyle = lsSolid then
      LineStyleText := 'solid;'
    else
      LineStyleText := 'dotted;';
    if toShowHorzGridLines in FOptions.FPaintOptions then
    begin
      Buffer.Add('.noborder{border-style:');
      Buffer.Add(LineStyleText);
      Buffer.Add(' border-bottom:1;border-left:0;border-right:0; border-top:0;');
      Buffer.Add(CellPadding);
      Buffer.Add('}');
    end
    else
    begin
      Buffer.Add('.noborder{border-style:none;');
      Buffer.Add(CellPadding);
      Buffer.Add('}');
    end;
    Buffer.AddNewLine;

    Buffer.Add('.normalborder {border-top:none; border-left:none; ');
    if toShowVertGridLines in FOptions.FPaintOptions then
      Buffer.Add('border-right:1 ' + LineStyleText)
    else
      Buffer.Add('border-right:none;');
    if toShowHorzGridLines in FOptions.FPaintOptions then
      Buffer.Add('border-bottom:1 ' + LineStyleText)
    else
      Buffer.Add('border-bottom:none;');
    Buffer.Add(CellPadding);
    Buffer.Add('}');
    Buffer.Add('</style>');
    Buffer.AddNewLine;

    // General table properties.
    Buffer.Add('<table class="default" bgcolor=');
    WriteColorAsHex(Color);
    Buffer.Add(AddHeader);
    Buffer.Add(' cellspacing="0" cellpadding=');
    Buffer.Add(IntToStr(FMargin) + '>');
    Buffer.AddNewLine;

    Columns := nil;
    Indices := nil;
    ColumnColors := nil;
    RenderColumns := FHeader.UseColumns;
    if RenderColumns then
    begin
      Columns := FHeader.FColumns.GetVisibleColumns;
      Indices := FHeader.FColumns.FPositionToIndex;
      SetLength(ColumnColors, Length(Columns));
    end;

    GetRenderStartValues(Source, Run, GetNextNode);
    Save := Run;
  
    MaxLevel := 0;
    // The table consists of visible columns and rows as used in the tree, but the main tree column is splitted
    // into several HTML columns to accomodate the indentation. 
    while Assigned(Run) do
    begin
      Level := GetNodeLevel(Run);
      If Level > MaxLevel then
        MaxLevel := Level;
      Run := GetNextNode(Run);
    end;

    if RenderColumns then
    begin
      Buffer.Add('<tr class="header" style="');
      Buffer.Add(CellPadding);
      Buffer.Add('">');
      Buffer.AddNewLine;
      // Make the first row in the HTML table an image of the tree header.
      for I := 0 to High(Columns) do
      begin
        Buffer.Add('<th height="');
        Buffer.Add(IntToStr(FHeader.FHeight));
        Buffer.Add('px"');
        Alignment := Columns[I].Alignment;
        // Consider directionality.
        if Columns[I].FBiDiMode <> bdLeftToRight then
        begin
          ChangeBidiModeAlignment(Alignment);
          Buffer.Add(' dir="rtl"');
        end;

          // Consider aligment.
        case Alignment of
          taRightJustify:
            Buffer.Add(' align=right');
          taCenter:
            Buffer.Add(' align=center');
        else
          Buffer.Add(' align=left');
        end;

        Index := Indices[Columns[I].Position];
        // Merge cells of the header emulation in the main column.
        if (MaxLevel > 0) and (Index = Header.MainColumn) then
        begin
          Buffer.Add(' colspan="');
          Buffer.Add(IntToStr(MaxLevel + 1));
          Buffer.Add('"');
        end;

        // The color of the header is usually clBtnFace.
        Buffer.Add(' bgcolor=');
        WriteColorAsHex(clBtnFace);

        // Set column width in pixels.
        Buffer.Add(' width="');
        Buffer.Add(IntToStr(Columns[I].Width));
        Buffer.Add('px">');

        if Length(Columns[I].Text) > 0 then
          Buffer.Add(UTF16ToUTF8(Columns[I].Text));
        Buffer.Add('</th>');
      end;
      Buffer.Add('</tr>');
      Buffer.AddNewLine;
    end;
  
    // Now go through the tree.
    Run := Save;
    while Assigned(Run) do
    begin
      Level := GetNodeLevel(Run);
      Buffer.Add(' <tr class="default">');
      Buffer.AddNewLine;

      I := 0;
      while (I < Length(Columns)) or not RenderColumns do
      begin
        if RenderColumns then
          Index := Indices[Columns[I].Position]
        else
          Index := NoColumn;

        if not RenderColumns or (coVisible in Columns[I].Options) then
        begin
          // Call back the application to know about font customization.
          Canvas.Font := Font;
          FFontChanged := False;
          DoPaintText(Run, Canvas, Index, ttNormal);

          if Index = Header.MainColumn then
          begin
            // Create a cell for each indentation level.
            if RenderColumns and not (coParentColor in Columns[I].FOptions) then
            begin
              for J := 1 to Level do
              begin
                Buffer.Add('<td class="noborder" width="');
                Buffer.Add(IndentWidth);
                Buffer.Add('" height="');
                Buffer.Add(IntToStr(Run.NodeHeight));
                Buffer.Add('px"');
                if not (coParentColor in Columns[I].FOptions) then
                begin
                  Buffer.Add(' bgcolor=');
                  WriteColorAsHex(Columns[I].Color);
                end;
                Buffer.Add('>&nbsp;</td>');
              end;
            end
            else
            begin
              for J := 1 to Level do
                if J = 1 then
                begin
                  Buffer.Add(' <td height="');
                  Buffer.Add(IntToStr(Run.NodeHeight));
                  Buffer.Add('px">&nbsp;</td>');
                end
                else
                  Buffer.Add(' <td>&nbsp;</td>');
            end;
          end;

          if FFontChanged then
          begin
            Buffer.Add(' <td class="normalborder" ');
            WriteStyle('', Canvas.Font);
            Buffer.Add(' height="');
            Buffer.Add(IntToStr(Run.NodeHeight));
            Buffer.Add('px"');
          end
          else
          begin
            Buffer.Add(' <td class="normalborder"  height="');
            Buffer.Add(IntToStr(Run.NodeHeight));
            Buffer.Add('px"');
          end;

          if RenderColumns then
          begin
            Alignment := Columns[I].Alignment;
            BidiMode := Columns[I].BidiMode;
          end
          else
          begin
            Alignment := Self.Alignment;
            BidiMode := Self.BidiMode;
          end;
          // Consider directionality.
          if BiDiMode <> bdLeftToRight then
          begin
            ChangeBidiModeAlignment(Alignment);
            Buffer.Add(' dir="rtl"');
          end;

          // Consider aligment.
          case Alignment of
            taRightJustify:
              Buffer.Add(' align=right');
            taCenter:
              Buffer.Add(' align=center');
          else
            Buffer.Add(' align=left');
          end;
          // Merge cells in the main column.
          if (MaxLevel > 0) and (Index = FHeader.MainColumn) and (Level < MaxLevel) then
          begin
            Buffer.Add(' colspan="');
            Buffer.Add(IntToStr(MaxLevel - Level + 1));
            Buffer.Add('"');
          end;
          if RenderColumns and not (coParentColor in Columns[I].FOptions) then
          begin
            Buffer.Add(' bgcolor=');
            WriteColorAsHex(Columns[I].Color);
          end;
          Buffer.Add('>');
          Text := Self.Text[Run, Index];
          if Length(Text) > 0 then
          begin
            Text := UTF16ToUTF8(Text);
            Buffer.Add(Text);
          end;
          Buffer.Add('</td>');
        end;

        if not RenderColumns then
          Break;
        Inc(I);
      end;
      Run := GetNextNode(Run);
      Buffer.Add(' </tr>');
      Buffer.AddNewLine;
    end;
    Buffer.Add('</table>');

    RestoreFontChangeEvent(Canvas);

    Result := Buffer.AsString;
  finally
    Buffer.Free;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualStringTree.ContentToRTF(Source: TVSTTextSourceType): string;

// Renders the current tree content (depending on Source) as RTF (rich text).
// Based on ideas and code from Frank van den Bergh and Andreas H�rstemeier.

var
  Fonts: TStringList;
  Colors: TList;
  CurrentFontIndex,
  CurrentFontColor,
  CurrentFontSize: Integer;
  Buffer: TBufferedString;
  
  //--------------- local functions -------------------------------------------

  procedure SelectFont(Font: string);

  var
    I: Integer;

  begin
    I := Fonts.IndexOf(Font);
    if I > -1 then
    begin
      // Font has already been used
      if I <> CurrentFontIndex then
      begin
        Buffer.Add('\f');
        Buffer.Add(IntToStr(I));
        CurrentFontIndex := I;
      end;
    end
    else
    begin
      I := Fonts.Add(Font);
      Buffer.Add('\f');
      Buffer.Add(IntToStr(I));
      CurrentFontIndex := I;
    end;
  end;

  //---------------------------------------------------------------------------

  procedure SelectColor(Color: TColor);

  var
    I: Integer;

  begin
    I := Colors.IndexOf(Pointer(Color));
    if I > -1 then
    begin
      // Color has already been used
      if I <> CurrentFontColor then
      begin
        Buffer.Add('\cf');
        Buffer.Add(IntToStr(I + 1));
        CurrentFontColor := I;
      end;
    end
    else
    begin
      I := Colors.Add(Pointer(Color));
      Buffer.Add('\cf');
      Buffer.Add(IntToStr(I + 1));
      CurrentFontColor := I;
    end;
  end;

  //---------------------------------------------------------------------------

  procedure TextPlusFont(Text: WideString; Font: TFont);

  var
    UseUnderline,
    UseItalic,
    UseBold: Boolean;
    I: Integer;

  begin
    if Length(Text) > 0 then
    begin
      UseUnderline := fsUnderline in Font.Style;
      if UseUnderline then
        Buffer.Add('\ul');
      UseItalic := fsItalic in Font.Style;
      if UseItalic then
        Buffer.Add('\i');
      UseBold := fsBold in Font.Style;
      if UseBold then
        Buffer.Add('\b');
      SelectFont(Font.Name);
      SelectColor(Font.Color);
      if Font.Size <> CurrentFontSize then
      begin
        // Font size must be given in half points.
        Buffer.Add('\fs');
        Buffer.Add(IntToStr(2 * Font.Size));
        CurrentFontSize := Font.Size;
      end;
      // Use escape sequences to note Unicode text.
      Buffer.Add(' ');
      // Note: Unicode values > 32767 must be expressed as negative numbers. This is implicitly done
      //       by interpreting the wide chars (word values) as small integers.
      for I := 1 to Length(Text) do
        Buffer.Add(Format('\u%d\''3f', [SmallInt(Text[I])]));
      if UseUnderline then
        Buffer.Add('\ul0');
      if UseItalic then
        Buffer.Add('\i0');
      if UseBold then
        Buffer.Add('\b0');
    end;
  end;

  //--------------- end local functions ---------------------------------------

var
  Level, LastLevel: Integer;
  I, J: Integer;
  Save, Run: PVirtualNode;
  GetNextNode: TGetNextNodeProc;
  S, Tabs : string;
  Text: WideString;
  Twips: Integer;

  RenderColumns: Boolean;
  Columns: TColumnsArray;
  Index: Integer;
  Indices: TIndexArray;
  Alignment: TAlignment;
  BidiMode: TBidiMode;

begin
  Buffer := TBufferedString.Create;
  try
    // For customization by the application or descentants we use again the redirected font change event.
    RedirectFontChangeEvent(Canvas);

    Fonts := TStringList.Create;
    Colors := TList.Create;
    CurrentFontIndex := -1;
    CurrentFontColor := -1;
    CurrentFontSize := -1;

    Columns := nil;
    Indices := nil;
    Tabs := '';
    LastLevel := 0;

    RenderColumns := FHeader.UseColumns;
    if RenderColumns then
    begin
      Columns := FHeader.FColumns.GetVisibleColumns;
      Indices := FHeader.FColumns.FPositionToIndex;
    end;

    GetRenderStartValues(Source, Run, GetNextNode);
    Save := Run;

    // First make a table structure. The \rtf and other header stuff is included
    // when the font and color tables are created.
    Buffer.Add('\uc1\trowd\trgaph70');
    J := 0;
    if RenderColumns then
    begin
      for I := 0 to High(Columns) do
      begin
        Inc(J, Columns[I].Width);
        // This value must be expressed in twips (1 inch = 1440 twips).
        Twips := Round(1440 * J / Screen.PixelsPerInch);
        Buffer.Add('\cellx');
        Buffer.Add(IntToStr(Twips));
      end;
    end
    else
    begin
      Twips := Round(1440 * ClientWidth / Screen.PixelsPerInch);
      Buffer.Add('\cellx');
      Buffer.Add(IntToStr(Twips));
    end;
    
    // Fill table header.
    if RenderColumns then
    begin
      Buffer.Add('\pard\intbl');
      for I := 0 to High(Columns) do
      begin
        Alignment := Columns[I].Alignment;
        BidiMode := Columns[I].BidiMode;

        // Alignment is not supported with older RTF formats, however it will be ignored.
        if BidiMode <> bdLeftToRight then
          ChangeBidiModeAlignment(Alignment);
        case Alignment of
          taRightJustify:
            Buffer.Add('\qr');
          taCenter:
            Buffer.Add('\qc');
        end;

        TextPlusFont(Columns[I].Text, Header.Font);
        Buffer.Add('\cell');
      end;
      Buffer.Add('\row');
    end;
  
    // Now write the contents.
    Run := Save;
    while Assigned(Run) do
    begin
      I := 0;
      while not RenderColumns or (I < Length(Columns)) do
      begin
        if RenderColumns then
        begin
          Index := Indices[Columns[I].Position];
          Alignment := Columns[I].Alignment;
          BidiMode := Columns[I].BidiMode;
        end
        else
        begin
          Index := NoColumn;
          Alignment := FAlignment;
          BidiMode := Self.BidiMode;
        end;
        
        if not RenderColumns or (coVisible in Columns[I].Options) then
        begin
          Text := Self.Text[Run, Index];
          Buffer.Add('\pard\intbl');

          // Alignment is not supported with older RTF formats, however it will be ignored.
          if BidiMode <> bdLeftToRight then
            ChangeBidiModeAlignment(Alignment);
          case Alignment of
            taRightJustify:
              Buffer.Add('\qr');
            taCenter:
              Buffer.Add('\qc');
          end;

          // Call back the application to know about font customization.
          Canvas.Font := Font;
          FFontChanged := False;
          DoPaintText(Run, Canvas, Index, ttNormal);

          if Index = Header.MainColumn then
          begin
            Level := GetNodeLevel(Run);
            if Level <> LastLevel then
            begin
              LastLevel := Level;
              Tabs := '';
              for J := 0 to Level - 1 do
                Tabs := Tabs + '\tab';
            end;
            if Level > 0 then
            begin
              Buffer.Add(Tabs);
              Buffer.Add(' ');
              TextPlusFont(Text, Canvas.Font);
              Buffer.Add('\cell');
            end
            else
            begin
              TextPlusFont(Text, Canvas.Font);
              Buffer.Add('\cell');
            end;
          end
          else
          begin
            TextPlusFont(Text, Canvas.Font);
            Buffer.Add('\cell');
          end;
        end;
        
        if not RenderColumns then
          Break;
        Inc(I);
      end;
      Buffer.Add('\row');
      Run := GetNextNode(Run);
    end;

    Buffer.Add('\pard\par');

    // Build lists with fonts and colors. They have to be at the start of the document.
    S := '{\rtf1\ansi\ansicpg1252\deff0\deflang1043{\fonttbl';
    for I := 0 to Fonts.Count - 1 do
      S := S + Format('{\f%d %s;}', [I, Fonts[I]]);
    S := S + '}';

    S := S + '{\colortbl;';
    for I := 0 to Colors.Count - 1 do
    begin
      J := ColorToRGB(TColor(Colors[I]));
      S := S + Format('\red%d\green%d\blue%d;', [J and $FF, (J shr 8) and $FF, (J shr 16) and $FF]);
    end;
    S := S + '}';

    Result := S + Buffer.AsString + '}';
    Fonts.Free;
    Colors.Free;

    RestoreFontChangeEvent(Canvas);
  finally
    Buffer.Free;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualStringTree.ContentToText(Source: TVSTTextSourceType; Separator: Char): string;

// Renders the current tree content (depending on Source) as plain ANSI text.
// Note: Unicode strings are implicitely converted to ANSI strings based on the currently active user locale.

var
  RenderColumns: Boolean;
  Tabs: string;
  GetNextNode: TGetNextNodeProc;
  Run, Save: PVirtualNode;
  Level, MaxLevel: Cardinal;
  Columns: TColumnsArray;
  LastColumn: TVirtualTreeColumn;
  Indices: TIndexArray;
  Index,
  I: Integer;
  Text: string;
  Buffer: TBufferedString;

begin
  Columns := nil;
  Indices := nil;
  Buffer := TBufferedString.Create;
  try
    RenderColumns := FHeader.UseColumns;
    if RenderColumns then
    begin
      Columns := FHeader.FColumns.GetVisibleColumns;
      Indices := FHeader.FColumns.FPositionToIndex;
    end;

    GetRenderStartValues(Source, Run, GetNextNode);
    Save := Run;

    // The text consists of visible groups representing the columns, which are separated by one or more separator
    // characters. There are always MaxLevel separator chars in a line (main column only). Either before the caption
    // to ident it or after the caption to make the following column aligned.
    MaxLevel := 0;
    while Assigned(Run) do
    begin
      Level := GetNodeLevel(Run);
      If Level > MaxLevel then
        MaxLevel := Level;
      Run := GetNextNode(Run);
    end;

    SetLength(Tabs, MaxLevel);
    FillChar(PChar(Tabs)^, MaxLevel, Separator);

    // First line is always the header if used.
    if RenderColumns then
    begin
      LastColumn := Columns[High(Columns)];
      for I := 0 to High(Columns) do
      begin
        Buffer.Add(Columns[I].Text);
        if Columns[I] <> LastColumn then
        begin
          if Indices[I] = Header.MainColumn then
          begin
            Buffer.Add(Tabs);
            Buffer.Add(Separator);
          end
          else
            Buffer.Add(Separator);
        end;
      end;
      Buffer.AddNewLine;
    end
    else
      LastColumn := nil;

    Run := Save;
    if RenderColumns then
    begin
      while Assigned(Run) do
      begin
        for I := 0 to High(Columns) do
        begin
          if coVisible in Columns[I].Options then
          begin
            Index := Indices[I];
            // This line implicitly converts the Unicode text to ANSI.
            Text := Self.Text[Run, Index];
            if Index = Header.MainColumn then
            begin
              Level := GetNodeLevel(Run);
              Buffer.Add(Copy(Tabs, 1, Level));
              Buffer.Add(Text);
              Buffer.Add(Copy(Tabs, 1, MaxLevel - Level));
            end
            else
              Buffer.Add(Text);

            if Columns[I] <> LastColumn then
              Buffer.Add(Separator);
          end;
        end;
        Run := GetNextNode(Run);
        Buffer.AddNewLine;
      end;
    end
    else
    begin
      while Assigned(Run) do
      begin
        // This line implicitely converts the Unicode text to ANSI.
        Text := Self.Text[Run, NoColumn];
        Level := GetNodeLevel(Run);
        Buffer.Add(Copy(Tabs, 1, Level));
        Buffer.Add(Text);
        Buffer.AddNewLine;

        Run := GetNextNode(Run);
      end;
    end;
    
    Result := Buffer.AsString;
  finally
    Buffer.Free;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualStringTree.ContentToUnicode(Source: TVSTTextSourceType; Separator: WideChar): WideString;

// Renders the current tree content (depending on Source) as Unicode text.

const
  WideCRLF: WideString = #13#10;

var
  RenderColumns: Boolean;
  Tabs: WideString;
  GetNextNode: TGetNextNodeProc;
  Run, Save: PVirtualNode;

  Columns: TColumnsArray;
  LastColumn: TVirtualTreeColumn;
  Indices: TIndexArray;
  Level, MaxLevel: Cardinal;
  Index,
  I: Integer;
  Text: WideString;
  Buffer: TWideBufferedString;

begin
  Columns := nil;
  Indices := nil;

  Buffer := TWideBufferedString.Create;
  try
    RenderColumns := FHeader.UseColumns;
    if RenderColumns then
    begin
      Columns := FHeader.FColumns.GetVisibleColumns;
      Indices := FHeader.FColumns.FPositionToIndex;
    end;

    GetRenderStartValues(Source, Run, GetNextNode);
    Save := Run;

    // The text consists of visible groups representing the columns, which are separated by one or more separator
    // characters. There are always MaxLevel separator chars in a line (main column only). Either before the caption
    // to ident it or after the caption to make the following column aligned.
    MaxLevel := 0;
    while Assigned(Run) do
    begin
      Level := GetNodeLevel(Run);
      If Level > MaxLevel then
        MaxLevel := Level;
      Run := GetNextNode(Run);
    end;

    SetLength(Tabs, MaxLevel);
    for I := 1 to MaxLevel do
      Tabs[I] := Separator;

    // First line is always the header if used.
    if RenderColumns then
    begin
      LastColumn := Columns[High(Columns)];
      for I := 0 to High(Columns) do
      begin
        Buffer.Add(Columns[I].Text);
        if Columns[I] <> LastColumn then
        begin
          if Indices[I] = Header.MainColumn then
          begin
            Buffer.Add(Tabs);
            Buffer.Add(Separator);
          end
          else
            Buffer.Add(Separator);
        end;
      end;
      Buffer.AddNewLine;
    end
    else
      LastColumn := nil;

    Run := Save;
    if RenderColumns then
    begin
      while Assigned(Run) do
      begin
        for I := 0 to High(Columns) do
        begin
          if coVisible in Columns[I].Options then
          begin
            Index := Indices[I];
            Text := Self.Text[Run, Index];
            if Index = Header.MainColumn then
            begin
              Level := GetNodeLevel(Run);
              Buffer.Add(Copy(Tabs, 1, Level));
              Buffer.Add(Text);
              Buffer.Add(Copy(Tabs, 1, MaxLevel - Level));
            end
            else
              Buffer.Add(Text);

            if Columns[I] <> LastColumn then
              Buffer.Add(Separator);
          end;
        end;
        Run := GetNextNode(Run);
        Buffer.AddNewLine;
      end;
    end
    else
    begin
      while Assigned(Run) do
      begin
        Text := Self.Text[Run, NoColumn];
        Level := GetNodeLevel(Run);
        Buffer.Add(Copy(Tabs, 1, Level));
        Buffer.Add(Text);
        Buffer.AddNewLine;

        Run := GetNextNode(Run);
      end;
    end;
    Result := Buffer.AsString;
  finally
    Buffer.Free;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualStringTree.InvalidateNode(Node: PVirtualNode): TRect;

var
  Data: PInteger;
  
begin
  Result := inherited InvalidateNode(Node);
  // Reset node width so changed text attributes are applied correctly.
  Data := InternalData(Node);
  if Assigned(Data) then
    Data^ := 0;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualStringTree.Path(Node: PVirtualNode; Column: Integer; TextType: TVSTTextType;
  Delimiter: WideChar): WideString;

// Constructs a string containing the node and all its parents. The last character in the returned path is always the
// given delimiter.

var
  S: WideString;

begin
  if (Node = nil) or (Node = FRoot) then
    Result := Delimiter
  else
  begin
    Result := '';
    while Node <> FRoot do
    begin
      DoGetText(Node, Column, TextType, S);
      Result := S + Delimiter + Result;
      Node := Node.Parent;
    end;
  end; 
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualStringTree.ReinitNode(Node: PVirtualNode; Recursive: Boolean);

begin
  inherited;
  // Reset node width so changed text attributes are applied correctly.
  if Assigned(Node) and (Node <> FRoot) then
    PInteger(InternalData(Node))^ := 0;
end;

//----------------- TVirtualStringTree ---------------------------------------------------------------------------------

function TVirtualStringTree.GetOptions: TStringTreeOptions;

begin
  Result := FOptions as TStringTreeOptions;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualStringTree.SetOptions(const Value: TStringTreeOptions);

begin
  FOptions.Assign(Value);
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualStringTree.GetOptionsClass: TTreeOptionsClass;

begin
  Result := TStringTreeOptions;
end;

//----------------- TCustomVirtualDrawTree -----------------------------------------------------------------------------

procedure TCustomVirtualDrawTree.DoDrawHint(Canvas: TCanvas; Node: PVirtualNode; R: TRect; Column: Integer);

begin
  if Assigned(FOnDrawHint) then
    FOnDrawHint(Self, Canvas, Node, R, Column);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualDrawTree.DoGetHintSize(Node: PVirtualNode; Column: Integer; var R: TRect);

begin
  if Assigned(FOnGetHintSize) then
    FOnGetHintSize(Self, Node, Column, R);
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualDrawTree.DoGetNodeWidth(Node: PVirtualNode; Column: Integer; Canvas: TCanvas = nil): Integer;

begin
  Result := 2 * FTextMargin;
  if Canvas = nil then
    Canvas := Self.Canvas;

  if Assigned(FOnGetNodeWidth) then
    FOnGetNodeWidth(Self, Canvas, Node, Column, Result);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualDrawTree.DoPaintNode(var PaintInfo: TVTPaintInfo);

begin
  if Assigned(FOnDrawNode) then
    FOnDrawNode(Self, PaintInfo);
end;

//----------------- TVirtualDrawTree -----------------------------------------------------------------------------------

function TVirtualDrawTree.GetOptions: TVirtualTreeOptions;

begin
  Result := FOptions as TVirtualTreeOptions;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVirtualDrawTree.SetOptions(const Value: TVirtualTreeOptions);

begin
  FOptions.Assign(Value);
end;

//----------------------------------------------------------------------------------------------------------------------

function TVirtualDrawTree.GetOptionsClass: TTreeOptionsClass;

begin
  Result := TVirtualTreeOptions;
end;

//----------------------------------------------------------------------------------------------------------------------

initialization
  InitializeGlobalStructures;
  // Native clipboard format. Needs a new identifier and has an average priority to allow other formats to take over.
  // This format is the only one which does not use the HGlobal storage format but instead it uses IStream.
  CF_VIRTUALTREE := RegisterVTClipboardFormat(CFSTR_VIRTUALTREE, TBaseVirtualTree, 50, TYMED_HGLOBAL or TYMED_ISTREAM);
  // Specialized string tree formats.
  CF_HTML := RegisterVTClipboardFormat(CFSTR_HTML, TCustomVirtualStringTree, 80);
  CF_VRTFNOOBJS := RegisterVTClipboardFormat(CFSTR_RTFNOOBJS, TCustomVirtualStringTree, 84);
  CF_VRTF := RegisterVTClipboardFormat(CFSTR_RTF, TCustomVirtualStringTree, 85);
  CF_CSV := RegisterVTClipboardFormat(CFSTR_CSV, TCustomVirtualStringTree, 90);
  // Predefined clipboard formats. Just add them to the internal list.
  RegisterVTClipboardFormat(CF_TEXT, TCustomVirtualStringTree, 100);
  RegisterVTClipboardFormat(CF_UNICODETEXT, TCustomVirtualStringTree, 95);
finalization
  FinalizeGlobalStructures;
end.

