//
//  EnhancedSearchBar.swift
//  RemoteRecruit
//
//  Created by Mehul Variya on 13/06/26.
//

import SwiftUI

struct EnhancedSearchBar: View {
    @Binding var searchText: String
    let onSearch: () -> Void
    let placeholder: String
    
    @FocusState private var isFocused: Bool
    
    init(searchText: Binding<String>,
         placeholder: String = "Search by job title or company...",
         onSearch: @escaping () -> Void) {
        self._searchText = searchText
        self.placeholder = placeholder
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
            TextField(placeholder, text: $searchText)
                .font(.system(size: 16))
                .focused($isFocused)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .onSubmit {
                    onSearch()
                    isFocused = false
                }
            
            // Clear Button
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    onSearch()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                }
                .transition(.scale.combined(with: .opacity))
            }
            
            // Search Button (shows only when typing or focused)
            if isFocused || !searchText.isEmpty {
                Button(action: {
                    onSearch()
                    isFocused = false
                    hideKeyboard()
                }) {
                    Text("Search")
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
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .padding(.horizontal, 16)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
