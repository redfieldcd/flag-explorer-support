import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedContinent: Continent = .all {
        didSet { reshuffleStudyCountries() }
    }
    @Published var currentCountry: Country?
    @Published var showAnswer: Bool = false
    @Published var studyIndex: Int = 0

    // Quiz state
    @Published var quizScore: Int = 0
    @Published var quizTotal: Int = 0
    @Published var quizOptions: [Country] = []
    @Published var selectedAnswer: Country?
    @Published var quizFinished: Bool = false
    @Published var quizQuestions: [Country] = []
    @Published var quizQuestionIndex: Int = 0

    // Progress
    @Published var learnedCountries: Set<String> = [] // country codes
    @Published var quizHistory: [QuizRecord] = []

    let speechManager = SpeechManager()
    private let questionsPerQuiz = 10

    struct QuizRecord: Identifiable {
        let id = UUID()
        let date: Date
        let score: Int
        let total: Int
        let continent: Continent
    }

    var filteredCountries: [Country] {
        CountryData.countries(for: selectedContinent)
    }

    @Published var shuffledStudyCountries: [Country] = []

    var studyCountries: [Country] {
        shuffledStudyCountries
    }

    var currentStudyCountry: Country? {
        let countries = studyCountries
        guard !countries.isEmpty, studyIndex >= 0, studyIndex < countries.count else { return nil }
        return countries[studyIndex]
    }

    var progressPercentage: Double {
        let total = CountryData.allCountries.count
        guard total > 0 else { return 0 }
        return Double(learnedCountries.count) / Double(total) * 100
    }

    // MARK: - Init
    init() {
        loadProgress()
        reshuffleStudyCountries()
    }

    func reshuffleStudyCountries() {
        shuffledStudyCountries = filteredCountries.shuffled()
    }

    // MARK: - Study Mode
    func startStudy() {
        reshuffleStudyCountries()
        studyIndex = 0
        showAnswer = false
    }

    func revealAnswer() {
        showAnswer = true
        if let country = currentStudyCountry {
            learnedCountries.insert(country.code)
            saveProgress()
            speechManager.speak(country.name)
        }
    }

    func nextStudyCard() {
        let countries = studyCountries
        if studyIndex < countries.count - 1 {
            studyIndex += 1
        } else {
            studyIndex = 0
        }
        showAnswer = false
    }

    func previousStudyCard() {
        if studyIndex > 0 {
            studyIndex -= 1
        } else {
            studyIndex = max(0, studyCountries.count - 1)
        }
        showAnswer = false
    }

    // MARK: - Quiz Mode
    func startQuiz() {
        let countries = filteredCountries
        quizQuestions = Array(countries.shuffled().prefix(questionsPerQuiz))
        quizQuestionIndex = 0
        quizScore = 0
        quizTotal = quizQuestions.count
        quizFinished = false
        selectedAnswer = nil
        loadNextQuizQuestion()
    }

    func loadNextQuizQuestion() {
        guard quizQuestionIndex < quizQuestions.count else {
            finishQuiz()
            return
        }

        let correct = quizQuestions[quizQuestionIndex]
        currentCountry = correct
        selectedAnswer = nil

        // Generate 3 wrong answers from the same pool
        var wrongAnswers = filteredCountries.filter { $0 != correct }.shuffled()
        wrongAnswers = Array(wrongAnswers.prefix(3))

        // Combine and shuffle
        var options = wrongAnswers + [correct]
        options.shuffle()
        quizOptions = options
    }

    func selectQuizAnswer(_ country: Country) {
        guard selectedAnswer == nil else { return }
        selectedAnswer = country

        if country == currentCountry {
            quizScore += 1
        }

        if let current = currentCountry {
            speechManager.speak(current.name)
            learnedCountries.insert(current.code)
            saveProgress()
        }

        // Auto-advance after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.quizQuestionIndex += 1
            self?.loadNextQuizQuestion()
        }
    }

    func finishQuiz() {
        quizFinished = true
        let record = QuizRecord(
            date: Date(),
            score: quizScore,
            total: quizTotal,
            continent: selectedContinent
        )
        quizHistory.insert(record, at: 0)
        if quizHistory.count > 20 {
            quizHistory = Array(quizHistory.prefix(20))
        }
    }

    // MARK: - Persistence
    private func saveProgress() {
        UserDefaults.standard.set(Array(learnedCountries), forKey: "learnedCountries")
    }

    private func loadProgress() {
        if let saved = UserDefaults.standard.stringArray(forKey: "learnedCountries") {
            learnedCountries = Set(saved)
        }
    }

    func resetProgress() {
        learnedCountries.removeAll()
        quizHistory.removeAll()
        saveProgress()
    }
}
