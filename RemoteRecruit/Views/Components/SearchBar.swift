//
//  SearchBar.swift
//  RemoteRecruit
//
//  Created by Mehul Variya on 13/06/26.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    var onSearch: (() -> Void)?
    
    init(text: Binding<String>, onSearch: (() -> Void)? = nil) {
        self._text = text
        self.onSearch = onSearch
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Animated Search Icon
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(isFocused ? .blue : .gray)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
            
            // Text Field
            TextField("Search by job title or company...", text: $text)
                .font(.system(size: 16))
                .focused($isFocused)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .onSubmit {
                    isFocused = false
                    onSearch?()
                }
            
            // Clear Button with animation
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    onSearch?()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                }
                .transition(.scale.combined(with: .opacity))
            }
            
            // Cancel/Search Button
            if isFocused || !text.isEmpty {
                Button(action: {
                    if isFocused {
                        isFocused = false
                        hideKeyboard()
                    }
                    onSearch?()
                }) {
                    Text(isFocused ? "Cancel" : "Search")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blue)
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFocused ? Color.blue : Color.gray.opacity(0.2), lineWidth: isFocused ? 2 : 1)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
