//
//  ContentView.swift
//  Task Manager
//
//  Created by Kevin Fairuz on 19/06/24.
//

import SwiftUI

struct ContentView: View {
    @State var currentDate: Date = .init()
    
    // Week Slider
    @State var weekSlider: [[Date.WeekDay]] = []
    @State var currentWeekIndex: Int = 1
    
    //Animation Namespace
    @Namespace private var animation
    
    @State private var createWeek: Bool = false
    
    // For Building The UI
    @State private var tasks:[Task] = sampleTask.sorted(by: {$1.date > $0.date})
    
    @State private var createNewTask: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0 ,content: {
            VStack(alignment: .leading, content: {
                Text("Calender")
                    .font(.system(size: 36, weight: .semibold))
                
                //Week Slider
                TabView(selection: $currentWeekIndex, content: {
                    ForEach(weekSlider.indices, id: \.self) { index in
                        let week = weekSlider[index]
                        weekView(week)
                            .tag(index)
                        
                    }
                })
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 90)
            })
            .padding()
            .frame(maxWidth: .infinity)
            .background{
                Rectangle().fill(.gray.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 40))
                    .ignoresSafeArea()
                
            }
            .onChange(of: currentWeekIndex, initial: false) {
                oldValue, newValue in
                if newValue == 0 || newValue == (weekSlider.count - 1 ) {
                    createWeek = true
                }
            }
            ScrollView(.vertical) {
                VStack {
                    // Task View
                    TaskView()
                }
                .hSpacing(.center)
                vSpacing(.center)
                
            }
            .scrollIndicators(.hidden)
            
        })
        .vSpacing(.top)
        .frame(maxWidth: .infinity)
        .onAppear(){
            if weekSlider.isEmpty {
                let currentWeek = Date().fetchWeek()
                if let firstDate = currentWeek.first?.date {
                    weekSlider.append(firstDate.createPreviousWeek())
                }
                
                weekSlider.append(currentWeek)
                
                if let lastDate = currentWeek.last?.date {
                    weekSlider.append(lastDate.createNextWeek())
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
                
                // Add New Task Toogle Button
                Button(action: {
                    createNewTask.toggle()
                }, label: {
                    Image(systemName: "plus")
                        .imageScale(.large)
                        .padding(26)
                        .background(.black)
                        .clipShape(Circle())
                        .padding([.horizontal])
                        .foregroundColor(.white)
                })
                .fullScreenCover(isPresented: $createNewTask, content: {
                    NewTask()
                })

        }
    }
    @ViewBuilder
    func weekView(_ week: [Date.WeekDay]) -> some View {
        HStack(spacing: 0){
            ForEach(week) {
                day in
                VStack {
                    Text(day.date.format("E"))
                        .font(.callout)
                        .fontWeight(.medium)
                        .textScale(.secondary)
                        .foregroundStyle(.gray)
                    
                    Text(day.date.format("dd"))
                        .font(.system(size: 20))
                        .frame(width: 40, height: 40)
                        .foregroundStyle(isSameDate(day.date, currentDate) ? .white : .black)
                        .background(content: {
                            if isSameDate(day.date, currentDate) {
                                RoundedRectangle(cornerRadius: 15).fill(.black)
                                    .offset(y: 3)
                                    .matchedGeometryEffect(id: "TABINDICATOR", in: animation)
                                
                            }
                            if day.date.isToday {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 5,height: 5)
                                    .vSpacing(.bottom)
                            }
                        })
                }
                .hSpacing(.center)
                .onTapGesture {
                    withAnimation(.snappy){
                        currentDate = day.date
                    }
                }
            }
        }
        .background{
            GeometryReader {
                let minX = $0.frame(in: .global).minX
                
                Color.clear
                    .preference(key: OffsetKey.self,value: minX)
                    .onPreferenceChange(OffsetKey.self, perform: { value in
                        if value.rounded() == 15 && createWeek {
                            paginateWeek()
                            createWeek = false
                        }
                    })
            }
        }
        
    }
    func paginateWeek()
    {
        if weekSlider.indices.contains(currentWeekIndex) {
            if let firstDate = weekSlider[currentWeekIndex].first?.date, currentWeekIndex == 0 {
                weekSlider.insert(firstDate.createPreviousWeek(), at:0)
                weekSlider.removeLast()
                currentWeekIndex = 1
            }
            
            if let lastDate = weekSlider[currentWeekIndex].last?.date, currentWeekIndex == (weekSlider.count - 1) {
                weekSlider.append(lastDate.createNextWeek())
                weekSlider.removeLast()
                currentWeekIndex = weekSlider.count - 2
            }
        }
    }
// Task View
    @ViewBuilder
    func TaskView() -> some View {
        VStack(alignment: .leading, content: {
            ForEach($tasks) { $task in
                TaskItem(task: $task)
                    .background(alignment: .leading) {
                        if tasks.last?.id != task.id {
                            Rectangle()
                                .frame(width: 1)
                                .offset(x: 24, y: 45)
                        }
                    }
            }
        })
        .padding(.top)
        
    }
    
}

struct ContentView_Priviews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
