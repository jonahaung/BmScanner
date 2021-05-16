//
//  TextEditorBar.swift
//  BmScanner
//
//  Created by Aung Ko Min on 10/5/21.
//

import SwiftUI

struct TextEditorBar: View {
    
    var manager: StateObject<TextEditorManger>
    
    var body: some View {
        VStack(spacing: 0) {
            if let bottomBarType = manager.wrappedValue.bottomBarType {
                switch bottomBarType {
                case .Traits:
                    traitsBar
                case .Alignment:
                    alignmentBar
                case .Font:
                    fontBar
                }
                Divider()
            } else{
                SuggesstionsView(manager: manager)
            }
            bottomBar
        }
        .font(.system(size: 17, weight: .medium, design: .serif))
    }
    
    private var editButton: some View {
        return Button {
            manager.wrappedValue.textView.toggleKeyboard()
        } label: {
            let imageName = manager.wrappedValue.textView.isEditable ? "chevron.down.circle.fill" : "pencil.circle.fill"
            Image(systemName: imageName)
                .font(.system(size: 30, weight: .semibold, design: .rounded))
        }
    }
    
    // Botom Bar
    private var bottomBar: some View {
        return HStack(spacing: 13) {
            Group {
                Button(action: {
                    manager.wrappedValue.textView.undoManager?.undo()
                }, label: {
                    Image(systemName: "arrow.counterclockwise")
                })
                .disabled(manager.wrappedValue.textView.undoManager?.canUndo == false)
                Button(action: {
                    manager.wrappedValue.textView.undoManager?.redo()
                }, label: {
                    Image(systemName: "arrow.clockwise")
                })
                .disabled(manager.wrappedValue.textView.undoManager?.canRedo == false)
            }
            
            Spacer()
            
            Group {
                Button(action: {
                    manager.wrappedValue.bottomBarType = manager.wrappedValue.bottomBarType == .Font ? nil : .Font
                }, label: {
                    Image(systemName: "textformat")
                    
                })
                
                Button(action: {
                    manager.wrappedValue.bottomBarType = manager.wrappedValue.bottomBarType == .Alignment ? nil : .Alignment
                }, label: {
                    Image(systemName: "text.alignleft")
                })
                Button(action: {
                    manager.wrappedValue.bottomBarType = manager.wrappedValue.bottomBarType == .Traits ? nil : .Traits
                }, label: {
                    Image(systemName: "bold.italic.underline")
                })
            }
            
            Group{
                Spacer()
                Button(action: {
                    manager.wrappedValue.actionSheetType = .EditMenuSheet
                }, label: {
                    Image(systemName: "ellipsis")
                })
                Spacer()
                editButton
            }
            
        }
        .padding()
    }
}

extension TextEditorBar {
    // Font
    private var fontBar: some View {
        return VStack {
            HStack{
                Spacer()
                closeButtonBarButton
                    .padding()
            }
            HStack{
                Text("Font")
                Spacer()
                Button {
                    manager.wrappedValue.sheetType = .FontPicker
                } label: {
                    Text(manager.wrappedValue.textStylingManager.fontName)
                }
            }
            Divider()
            ColorPicker("Text Color", selection: manager.projectedValue.styleColor, supportsOpacity: false)
                .foregroundColor(Color(manager.wrappedValue.textStylingManager.textColor))
            Divider()
            HStack{
                Text("Font Size")
                Spacer()
                Group{
                    Button(action: {
                        manager.wrappedValue.textStylingManager.updateFontSize(diff: -0.5)
                    }, label: {
                        Image(systemName: "minus.circle.fill")
                    })
                    
                    Button(action: {
                        manager.wrappedValue.textStylingManager.updateFontSize(diff: 0.5)
                    }, label: {
                        Image(systemName: "plus.circle.fill")
                    })
                }.font(.title2)
            }
        }
        .padding()
    }
    
    // Traits
    private var traitsBar: some View {
        return HStack {
            Group{
                Spacer()
                Button {
                    manager.wrappedValue.textStylingManager.toggleHighlight(color: .systemYellow)
                } label: {
                    Image(systemName: "highlighter")
                }
                Spacer()
                Button(action: {
                    manager.wrappedValue.textView.toggleBoldface(nil)
                }, label: {
                    Image(systemName: "bold")
                })
                Spacer()
                Button(action: {
                    manager.wrappedValue.textView.toggleItalics(nil)
                }, label: {
                    Image(systemName: "italic")
                })
            }
            Group{
                Spacer()
                Button(action: {
                    manager.wrappedValue.textView.toggleUnderline(nil)
                }, label: {
                    Image(systemName: "underline")
                })
                Spacer()
                Button(action: {
                    manager.wrappedValue.textStylingManager.toggleStrikeThrough()
                }, label: {
                    Image(systemName: "strikethrough")
                })
                Spacer()
            }
            Spacer()
            closeButtonBarButton
        }.padding()
    }
    
    // Alignment
    private var alignmentBar: some View {
        return HStack {
            Spacer()
            Button(action: {
                manager.wrappedValue.textStylingManager.updateAlignment(alignment: .left)
            }, label: {
                Image(systemName: "text.alignleft")
            })
            
            Spacer()
            Button(action: {
                manager.wrappedValue.textStylingManager.updateAlignment(alignment: .center)
            }, label: {
                Image(systemName: "text.aligncenter")
            })
            Spacer()
            Button(action: {
                manager.wrappedValue.textStylingManager.updateAlignment(alignment: .right)
            }, label: {
                Image(systemName: "text.alignright")
            })
            Spacer()
            Button(action: {
                manager.wrappedValue.textStylingManager.updateAlignment(alignment: .justified)
            }, label: {
                Image(systemName: "text.justify")
            })
            Spacer()
            closeButtonBarButton
        }.padding()
    }
    
    private var closeButtonBarButton: some View {
        return Button(action: {
            manager.wrappedValue.bottomBarType = nil
        }, label: {
            Image(systemName: "chevron.down")
        })
    }
}
