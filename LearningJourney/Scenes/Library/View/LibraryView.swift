import SwiftUI
import Neumorphic

struct LearningGoalsView: View {
    
    let goals: [LearningGoal]
    let title: String
    
    var body: some View {
        Text("Salve")
            .navigationTitle(title)
    }
}

struct LibraryView: View {
    @Environment(\.appEnvironment) private var appEnvironment: AppEnvironment
    @StateObject private var viewModel: ViewModel
    
    @State private var isPresentingGoals: Bool = true
    
    init(
        viewModel: ViewModel
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.Neumorphic.main
                    .ignoresSafeArea()
                ScrollView(.vertical) {
                    VStack {
                        ForEach(viewModel.sections, id: \.name) { section in
                            buildQuickActionSection(
                                title: section.name,
                                using: section.objectives
                            )
                        }
                        HStack {
                            Text("All")
                                .font(.title2)
                                .bold()
                            Spacer()
                        }
                        .padding(.top, 24)
                        buildStrandsSection(using: viewModel.strands)
                    }
                }
                .padding()
            }
            .navigationTitle("Library")
        }
        .onAppear {
            viewModel.initialize()
        }
    }
    
    private func buildQuickActionSection(title: String, using objectives: [LearningObjective]) -> some View {
        VStack {
            HStack {
                Text(title)
                    .font(.title2)
                    .bold()
                
                Spacer()
            }
            
            VStack {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(objectives, id: \.id) { objective in
                            ObjectiveView(objective: objective)
                        }
                    }
                }
            }
        }
    }
    
    private func buildStrandsSection(using strands: [LearningStrand]) -> some View{
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.Neumorphic.main)
                    .softOuterShadow()
                VStack {
                    ForEach(strands, id: \.name) { strand in
                        NavigationLink(destination: LearningGoalsView(
                                        goals: strand.goals,
                                        title: strand.name
                        )) {
                            HStack {
                                Text(strand.name)
                                    .padding(.leading, 32)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .padding(.trailing, 32)
                            }
                            .padding(.vertical, 16)
                        
                        }
                        .foregroundColor(.black)
                    }
                }
                .padding(.vertical, 8)
                
            }
            
        }
        .padding()
    }
}


extension LibraryView {
    final class ViewModel: ObservableObject {
        struct Section {
            let name: String
            let objectives: [LearningObjective]
        }
        
        @Published var sections: [Section] = []
        @Published var strands: [LearningStrand] = []
        
        // MARK: - Inner types
        struct Dependencies {
            let fetchInProgressObjectives: FetchInProgressObjectivesUseCase
            let fetchRecommendationObjectivesUseCase: FetchRecommendationObjectivesUseCase
            let fetchLearningStrandsUseCase: FetchLearningStrandsUseCase
        }
        
        // MARK: - Dependencies
        
        private let dependencies: Dependencies
        
        // MARK: - Initialization
        
        init(dependencies: Dependencies) {
            self.dependencies = dependencies
        }
                    
        // MARK: - LibraryDisplayLogic
        func initialize() {
            dependencies.fetchInProgressObjectives.execute {
                switch $0 {
                case let .success(objectives):
                    self.sections.append(.init(
                        name: "In Progress",
                        objectives: objectives
                    ))
                case let .failure(error):
                    print("Erro! \(error)")
                }
            }
            dependencies.fetchRecommendationObjectivesUseCase.execute {
                switch $0 {
                case let .success(objectives):
                    self.sections.append(.init(
                        name: "Recommendations",
                        objectives: objectives
                    ))
                case let .failure(error):
                    print("Error fetching recommendations! \(error)")
                }
            }
            dependencies.fetchLearningStrandsUseCase.execute { (result) in
                switch result {
                case let .success(strands):
                    self.strands = strands
                case let .failure(error): print("Error fetching strands! \(error)")
                }
            }
        }
    }
    
    func handleStrandSelection(on strand: LearningStrand) {
        print("Strand is \(strand)")
    }
    
}

#if DEBUG
struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView(viewModel: .init(dependencies: .init(
            fetchInProgressObjectives: PreviewFetchInProgressObjectivesUseCase(),
            fetchRecommendationObjectivesUseCase: PreviewFetchRecommendationObjectivesUseCase(),
            fetchLearningStrandsUseCase: PreviewFetchLearningStrandsUseCase()
        )))
        .previewDevice("iPhone 8")
    }
}

final class PreviewFetchInProgressObjectivesUseCase: FetchInProgressObjectivesUseCase {
    func execute(then handle: (Result<[LearningObjective], Error>) -> Void) {
        handle(.failure(NSError(domain: "", code: 1, userInfo: nil)))
    }
}

final class PreviewFetchRecommendationObjectivesUseCase: FetchRecommendationObjectivesUseCase {
    func execute(then handle: (Result<[LearningObjective], Error>) -> Void) {
        handle(.success([
            .init(
                coreKeywords: [],
                electiveKeywords: [],
                name: "Learn about monetization and business decisions that need to be made when planning the development of an app."
            ),
            .init(
                coreKeywords: [],
                electiveKeywords: [],
                name: "Learn about monetization and business decisions that need to be made when planning the development of an app."
            ),
            .init(
                coreKeywords: [],
                electiveKeywords: [],
                name: "Learn about monetization and business decisions that need to be made when planning the development of an app."
            ),
            .init(
                coreKeywords: [],
                electiveKeywords: [],
                name: "Learn about monetization and business decisions that need to be made when planning the development of an app."
            ),
            .init(
                coreKeywords: [],
                electiveKeywords: [],
                name: "Learn about monetization and business decisions that need to be made when planning the development of an app."
            ),
        ]))
    }
}

final class PreviewFetchLearningStrandsUseCase: FetchLearningStrandsUseCase {
    func execute(then handle: (Result<[LearningStrand], Error>) -> Void) {
        handle(.success([
            .init(
                name: "Design",
                goals: []
            ),
            .init(
                name: "Programming",
                goals: []
            ),
            .init(
                name: "Metaskills",
                goals: []
            ),
            .init(
                name: "Process",
                goals: []
            ),
        ]))
    }
}
#endif
