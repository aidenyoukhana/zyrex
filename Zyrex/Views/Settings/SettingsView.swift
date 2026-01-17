//
//  SettingsView.swift
//  Zyrex
//
//  Created by Aiden Youkhana on 1/17/26.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @State var viewModel: SettingsViewModel
    @State private var showingClearDataAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                // Profile section
                profileSection
                
                // Goals section
                goalsSection
                
                // Maximoo character section
                maximooSection
                
                // Notifications section
                notificationsSection
                
                // App settings section
                appSettingsSection
                
                // Data section
                dataSection
                
                // About section
                aboutSection
            }
            .navigationTitle("Settings")
            .onAppear {
                viewModel.loadData()
            }
            .onChange(of: viewModel.soundEnabled) { _, _ in viewModel.saveChanges() }
            .onChange(of: viewModel.hapticsEnabled) { _, _ in viewModel.saveChanges() }
            .onChange(of: viewModel.dailyReminderEnabled) { _, _ in viewModel.saveChanges() }
            .alert("Clear All Data?", isPresented: $showingClearDataAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    viewModel.clearAllData()
                }
            } message: {
                Text("This will delete all workout history and reset your stats. This cannot be undone.")
            }
        }
    }
    
    // MARK: - Profile Section
    
    private var profileSection: some View {
        Section {
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(.orange.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "person.fill")
                        .font(.title)
                        .foregroundStyle(.orange)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    TextField("Name", text: $viewModel.userName)
                        .font(.headline)
                        .onSubmit {
                            viewModel.saveChanges()
                        }
                    
                    Text("Member since \(viewModel.memberSince, format: .dateTime.month().year())")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 8)
            
            // Stats
            HStack {
                VStack {
                    Text("\(viewModel.totalWorkoutsCompleted)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Workouts")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                
                VStack {
                    Text("\(viewModel.totalMinutesExercised)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Minutes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 8)
        } header: {
            Text("Profile")
        }
    }
    
    // MARK: - Goals Section
    
    private var goalsSection: some View {
        Section {
            Picker("Fitness Level", selection: $viewModel.fitnessLevel) {
                ForEach(Difficulty.allCases, id: \.self) { level in
                    Text(level.rawValue).tag(level)
                }
            }
            .onChange(of: viewModel.fitnessLevel) { _, _ in
                viewModel.saveChanges()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Weekly Goal")
                    Spacer()
                    Text("\(viewModel.weeklyGoalMinutes) min")
                        .foregroundStyle(.secondary)
                }
                
                Slider(
                    value: Binding(
                        get: { Double(viewModel.weeklyGoalMinutes) },
                        set: { viewModel.weeklyGoalMinutes = Int($0) }
                    ),
                    in: 30...500,
                    step: 10
                )
                .tint(.orange)
                .onChange(of: viewModel.weeklyGoalMinutes) { _, _ in
                    viewModel.saveChanges()
                }
            }
        } header: {
            Text("Goals")
        }
    }
    
    // MARK: - Maximoo Section
    
    private var maximooSection: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.maximooCharacters) { character in
                        MaximooCharacterCard(
                            character: character,
                            isSelected: viewModel.selectedMaximooCharacter == character.id
                        ) {
                            viewModel.selectCharacter(character.id)
                            viewModel.saveChanges()
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        } header: {
            Text("Maximoo Character")
        }
    }
    
    // MARK: - Notifications Section
    
    private var notificationsSection: some View {
        Section {
            Toggle("Daily Reminder", isOn: $viewModel.dailyReminderEnabled)
            
            if viewModel.dailyReminderEnabled {
                DatePicker(
                    "Reminder Time",
                    selection: $viewModel.reminderTime,
                    displayedComponents: .hourAndMinute
                )
                .onChange(of: viewModel.reminderTime) { _, _ in
                    viewModel.saveChanges()
                }
            }
        } header: {
            Text("Notifications")
        }
    }
    
    // MARK: - App Settings Section
    
    private var appSettingsSection: some View {
        Section {
            Toggle(isOn: $viewModel.soundEnabled) {
                Label("Sound Effects", systemImage: "speaker.wave.2.fill")
            }
            
            Toggle(isOn: $viewModel.hapticsEnabled) {
                Label("Haptic Feedback", systemImage: "hand.tap.fill")
            }
        } header: {
            Text("App Settings")
        }
    }
    
    // MARK: - Data Section
    
    private var dataSection: some View {
        Section {
            Button {
                viewModel.exportData()
            } label: {
                Label("Export Data", systemImage: "square.and.arrow.up")
            }
            
            Button(role: .destructive) {
                showingClearDataAlert = true
            } label: {
                Label("Clear All Data", systemImage: "trash")
            }
        } header: {
            Text("Data")
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.secondary)
            }
            
            Link(destination: URL(string: "https://example.com/privacy")!) {
                HStack {
                    Text("Privacy Policy")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .foregroundStyle(.primary)
            
            Link(destination: URL(string: "https://example.com/terms")!) {
                HStack {
                    Text("Terms of Service")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .foregroundStyle(.primary)
        } header: {
            Text("About")
        } footer: {
            Text("Made with ❤️ and Maximoo")
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 20)
        }
    }
}

// MARK: - Supporting Views

struct MaximooCharacterCard: View {
    let character: MaximooCharacter
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? .orange.opacity(0.15) : .gray.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "figure.wave")
                        .font(.largeTitle)
                        .foregroundStyle(isSelected ? .orange : .gray)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? .orange : .clear, lineWidth: 2)
                )
                
                Text(character.name)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? .primary : .secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: 90)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel(modelContext: ModelContext(try! ModelContainer(for: UserProfile.self))))
}
