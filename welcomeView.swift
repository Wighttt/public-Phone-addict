import SwiftUI
import Firebase
import FirebaseAuth

struct WelcomeView: View {
    // State variables
    @State private var isEnterpriseSelected = false
    @State private var isAdminSelected = false
    @State private var showLoginOptions = false
    @State private var titleOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var typingText = ""
    @State private var fullText = "Réparation professionnelle d'appareils mobiles"
    @State private var typingIndex = 0
    @State private var email = ""
    @State private var password = ""
    @State private var adminEmail = ""
    @State private var adminPassword = ""
    @State private var companyName = ""
    @State private var phoneNumber = ""
    @State private var currentView = "main"
    @State private var animateBackground = false
    @State private var showMenu = false
    @State private var navigateToAdmin: Bool = false
    
    // Variables pour l'authentification
    @State private var isAuthenticating = false
    @State private var authenticationError: String? = nil
    @State private var showEnterpriseMainView = false
    
    @EnvironmentObject var databaseService: DatabaseService
    
    // Colors
    let primaryColor = Color.black
    let accentColor = Color(red: 255/255, green: 96/255, blue: 0/255)
    let textColor = Color.white
    let secondaryColor = Color(red: 30/255, green: 30/255, blue: 30/255)
    let darkBackgroundColor = Color(red: 10/255, green: 10/255, blue: 12/255)
    
    // Animations
    let springAnimation = Animation.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Darker Gradient Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        darkBackgroundColor,
                        Color(red: 18/255, green: 18/255, blue: 22/255)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Fullscreen cover to navigate to AdminMainView with better error handling
                .fullScreenCover(isPresented: $navigateToAdmin) {
                    // Quand l'utilisateur revient de la vue admin
                    print("Retour de la vue AdminMainView")
                } content: {
                    AdminMainView()
                        .environmentObject(databaseService)
                        .onAppear {
                            print("AdminMainView est apparue")
                        }
                }
                
                // Subtle grid pattern overlay
                GridPatternView()
                    .opacity(0.07)
                    .ignoresSafeArea()
                
                // Tech overlay pattern
                CircuitPatternView(animate: $animateBackground)
                    .opacity(0.1)
                    .ignoresSafeArea()
                
                // Main layout
                VStack(spacing: 0) {
                    // Header bar for mobile with menu button - MODIFIÉ: seuil passé à 1024 pour inclure les tablettes
                    if geometry.size.width < 1024 {
                        HStack {
                            Button(action: {
                                withAnimation(.spring()) {
                                    showMenu = true
                                }
                            }) {
                                Image(systemName: "line.horizontal.3")
                                    .font(.system(size: 20))
                                    .foregroundColor(textColor)
                                    .padding(10)
                                    .background(Color.black.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            .padding(.leading, 15)
                            .padding(.top, 15)
                            
                            Spacer()
                        }
                    }
                    
                    // Main content area
                    ScrollView {
                        VStack(spacing: 0) {
                            // Header Area with Logo and Title
                            headerView(geometry: geometry)
                                .padding(.top, geometry.size.height * (geometry.size.width >= 768 ? 0.05 : 0.02))
                            
                            Spacer()
                                .frame(height: 40)
                            
                            // Dynamic content based on current view
                            ZStack {
                                // MAIN VIEW
                                if currentView == "main" {
                                    mainSelectionView()
                                        .transition(.asymmetric(
                                            insertion: .opacity.combined(with: .scale(scale: 1, anchor: .center)),
                                            removal: .move(edge: .leading).combined(with: .opacity)
                                        ))
                                }
                                
                                // LOGIN OPTIONS VIEW
                                else if currentView == "loginOptions" {
                                    enterpriseOptionsView()
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .trailing).combined(with: .opacity)
                                        ))
                                }
                                
                                // ADMIN LOGIN VIEW
                                else if currentView == "adminLogin" {
                                    adminLoginView()
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .trailing).combined(with: .opacity)
                                        ))
                                }
                                
                                // ENTERPRISE LOGIN VIEW
                                else if currentView == "enterpriseLogin" {
                                    enterpriseLoginView()
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .trailing).combined(with: .opacity)
                                        ))
                                }
                                
                                // ENTERPRISE REGISTRATION VIEW
                                else if currentView == "enterpriseRegistration" {
                                    enterpriseRegistrationView()
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .trailing).combined(with: .opacity)
                                        ))
                                }
                            }
                            
                            // Show features section on iPad or when in main view
                            if geometry.size.width >= 768 || currentView == "main" {
                                featuresSection()
                                    .padding(.top, 60)
                            }
                            
                            // Footer always visible
                            footerView()
                                .padding(.top, 60)
                        }
                        .padding(.bottom, 40)
                        .frame(minHeight: geometry.size.height - 80)
                    }
                }
                
                // Menu modal overlay - MODIFIÉ pour s'afficher correctement sur les tablettes
                if showMenu {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring()) {
                                showMenu = false
                            }
                        }
                    
                    // Position différente selon la taille de l'écran
                    GeometryReader { menuGeometry in
                        HStack(spacing: 0) {
                            // Menu modal avec effet de carte
                            VStack(spacing: 0) {
                                // En-tête du menu
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack {
                                        Image(systemName: "iphone.gen3")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 32, height: 32)
                                            .foregroundColor(accentColor)
                                        
                                        Text("PHONNE ADDICT")
                                            .font(.custom("Avenir-Heavy", size: 20))
                                            .tracking(1)
                                            .foregroundColor(textColor)
                                        
                                        Spacer()
                                        
                                        // Bouton fermer
                                        Button(action: {
                                            withAnimation(.spring()) {
                                                showMenu = false
                                            }
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 24))
                                                .foregroundColor(Color.gray.opacity(0.7))
                                        }
                                    }
                                    
                                    Text("Services professionnels")
                                        .font(.custom("Avenir-Medium", size: 14))
                                        .foregroundColor(Color.gray)
                                }
                                .padding(.vertical, 25)
                                .padding(.horizontal, 25)
                                .background(Color(red: 22/255, green: 22/255, blue: 27/255))
                                
                                Divider()
                                    .background(Color.gray.opacity(0.3))
                                
                                // Options de menu
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 5) {
                                        MenuButton(icon: "building.2", title: "Entreprises", isActive: true) {
                                            withAnimation(.spring()) {
                                                showMenu = false
                                            }
                                        }
                                        
                                        MenuButton(icon: "person", title: "Particuliers", isActive: false) {
                                            withAnimation(.spring()) {
                                                showMenu = false
                                            }
                                        }
                                        
                                        MenuButton(icon: "gearshape", title: "Services", isActive: false) {
                                            withAnimation(.spring()) {
                                                showMenu = false
                                            }
                                        }
                                        
                                        MenuButton(icon: "questionmark.circle", title: "Support", isActive: false) {
                                            withAnimation(.spring()) {
                                                showMenu = false
                                            }
                                        }
                                        
                                        Divider()
                                            .background(Color.gray.opacity(0.3))
                                            .padding(.vertical, 10)
                                        
                                        // Information de contact
                                        VStack(alignment: .leading, spacing: 15) {
                                            Text("CONTACT")
                                                .font(.custom("Avenir-Heavy", size: 14))
                                                .tracking(1)
                                                .foregroundColor(Color.gray.opacity(0.7))
                                            
                                            HStack(spacing: 12) {
                                                Image(systemName: "envelope.fill")
                                                    .foregroundColor(accentColor.opacity(0.8))
                                                
                                                Text("contact@phonneaddict.com")
                                                    .font(.custom("Avenir-Medium", size: 14))
                                                    .foregroundColor(Color.gray)
                                            }
                                            
                                            HStack(spacing: 12) {
                                                Image(systemName: "phone.fill")
                                                    .foregroundColor(accentColor.opacity(0.8))
                                                
                                                Text("+33 1 23 45 67 89")
                                                    .font(.custom("Avenir-Medium", size: 14))
                                                    .foregroundColor(Color.gray)
                                            }
                                        }
                                        .padding(20)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.black.opacity(0.3))
                                        )
                                        .padding(.horizontal, 15)
                                        .padding(.top, 5)
                                    }
                                    .padding(.vertical, 10)
                                }
                                
                                Spacer()
                            }
                            .frame(width: geometry.size.width >= 768 ? 400 : min(350, geometry.size.width * 0.85),
                                   height: geometry.size.height * 0.85)
                            .background(Color(red: 18/255, green: 18/255, blue: 22/255))
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.5), radius: 20, x: 0, y: 0)
                            
                            Spacer() // Pousse le menu vers la gauche
                        }
                        .padding(.leading, 20) // Marge à gauche seulement
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    }
                    .transition(.move(edge: .leading).combined(with: .opacity))
                    .zIndex(10)
                }
                
                // Fullscreen cover pour naviguer vers EnterpriseMainView
                if showEnterpriseMainView {
                    EnterpriseMainView()
                        .transition(.opacity)
                        .zIndex(100)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            // Start animations when view appears
            startAnimations()
            
            // Logging pour debug
            print("WelcomeView apparaît")
            
            // Check if user is already logged in
            if let currentUser = databaseService.currentUser {
                print("Utilisateur déjà connecté: \(currentUser.email), isAdmin: \(currentUser.isAdmin)")
                
                if currentUser.isAdmin {
                    // Si utilisateur admin connecté, rediriger vers vue admin avec délai
                    print("Redirection vers vue admin pour l'utilisateur connecté")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        print("Navigation automatique vers AdminMainView...")
                        self.navigateToAdmin = true
                    }
                } else {
                    // Si utilisateur entreprise connecté, rediriger vers vue entreprise
                    print("Redirection vers vue entreprise pour l'utilisateur connecté")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            showEnterpriseMainView = true
                        }
                    }
                }
            } else {
                print("Aucun utilisateur connecté")
            }
        }
    }
    
    // MARK: - Menu Button
    private struct MenuButton: View {
        var icon: String
        var title: String
        var isActive: Bool
        var action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 15) {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(isActive ? Color(red: 255/255, green: 96/255, blue: 0/255) : Color.gray.opacity(0.8))
                        .frame(width: 24)
                    
                    Text(title)
                        .font(.custom("Avenir-Medium", size: 16))
                        .foregroundColor(isActive ? Color.white : Color.gray.opacity(0.8))
                    
                    Spacer()
                    
                    if isActive {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 255/255, green: 96/255, blue: 0/255))
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(Color.gray.opacity(0.6))
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 25)
                .background(
                    isActive ? Color.black.opacity(0.3) : Color.clear
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // [Le reste du code reste identique...]
    
    // MARK: - Header View
    private func headerView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 16) {
            // Only show logo in header on small screens (hide on iPad with sidebar)
            if geometry.size.width < 768 {
                ZStack {
                    // Subtle glow behind logo
                    Circle()
                        .fill(accentColor.opacity(0.05))
                        .frame(width: 90, height: 90)
                        .blur(radius: 10)
                        .opacity(titleOpacity)
                    
                    // Logo Container
                    ZStack {
                        // Base circle
                        Circle()
                            .fill(Color.black.opacity(0.5))
                            .frame(width: 80, height: 80)
                        
                        // Logo icon
                        Image(systemName: "iphone.gen3")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36, height: 36)
                            .foregroundColor(accentColor)
                        
                        // Ring
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [accentColor, accentColor.opacity(0.3)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                            .frame(width: 80, height: 80)
                    }
                    .opacity(titleOpacity)
                }
                
                // Title with modern formatting
                Text("PHONNE ADDICT")
                    .font(.custom("Avenir-Heavy", size: 28))
                    .tracking(1.5)
                    .foregroundColor(textColor)
                    .opacity(titleOpacity)
            }
            
            // Animated subtitle
            Text(typingText)
                .font(.custom("Avenir-Medium", size: 16))
                .foregroundColor(Color.gray.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .padding(.top, 5)
                .opacity(titleOpacity)
        }
    }
    // MARK: - Main Selection View
    private func mainSelectionView() -> some View {
        VStack(spacing: 25) {
            Text("SÉLECTIONNEZ VOTRE PROFIL")
                .font(.custom("Avenir-Heavy", size: 15))
                .tracking(1)
                .foregroundColor(Color.gray.opacity(0.8))
                .padding(.bottom, 15)
            
            // Enterprise Button
            ProfessionalButton(
                title: "ENTREPRISE",
                icon: "building.2",
                color: accentColor,
                action: {
                    withAnimation(springAnimation) {
                        currentView = "loginOptions"
                    }
                }
            )
            .opacity(contentOpacity)
            
            // Admin Button
            ProfessionalButton(
                title: "ADMINISTRATEUR",
                icon: "person.badge.key",
                color: secondaryColor,
                iconColor: accentColor,
                action: {
                    withAnimation(springAnimation) {
                        currentView = "adminLogin"
                    }
                }
            )
            .opacity(contentOpacity)
        }
        .frame(maxWidth: 360)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Enterprise Options View
    private func enterpriseOptionsView() -> some View {
        VStack(spacing: 25) {
            Text("OPTIONS D'ENTREPRISE")
                .font(.custom("Avenir-Heavy", size: 15))
                .tracking(1)
                .foregroundColor(Color.gray.opacity(0.8))
                .padding(.bottom, 15)
            
            // Login Button
            ProfessionalButton(
                title: "SE CONNECTER",
                icon: "arrow.right.circle",
                color: accentColor,
                action: {
                    withAnimation(springAnimation) {
                        currentView = "enterpriseLogin"
                    }
                }
            )
            
            // Register Button
            ProfessionalButton(
                title: "S'INSCRIRE",
                icon: "plus.circle",
                color: secondaryColor,
                iconColor: accentColor,
                action: {
                    withAnimation(springAnimation) {
                        currentView = "enterpriseRegistration"
                    }
                }
            )
            
            // Back Button
            ProfessionalBackButton {
                withAnimation(springAnimation) {
                    currentView = "main"
                }
            }
        }
        .frame(maxWidth: 360)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Admin Login View
    private func adminLoginView() -> some View {
        VStack(spacing: 20) {
            Text("CONNEXION ADMINISTRATEUR")
                .font(.custom("Avenir-Heavy", size: 15))
                .tracking(1)
                .foregroundColor(Color.gray.opacity(0.8))
                .padding(.bottom, 15)
            
            ProfessionalTextField(
                placeholder: "Email",
                text: $adminEmail,
                icon: "envelope"
            )
            
            ProfessionalTextField(
                placeholder: "Mot de passe",
                text: $adminPassword,
                icon: "lock",
                isSecure: true
            )
            
            // Error message if login failed
            if let error = authenticationError {
                Text(error)
                    .font(.custom("Avenir-Medium", size: 14))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Login button with loading state
            if isAuthenticating {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: accentColor))
                    .scaleEffect(1.5)
                    .padding(.top, 10)
            } else {
                ProfessionalButton(
                    title: "SE CONNECTER",
                    icon: "arrow.right.circle",
                    color: accentColor,
                    action: {
                        adminLogin()
                    }
                )
                .padding(.top, 10)
            }
            
            // Back Button
            ProfessionalBackButton {
                withAnimation(springAnimation) {
                    adminEmail = ""
                    adminPassword = ""
                    authenticationError = nil
                    currentView = "main"
                }
            }
        }
        .frame(maxWidth: 360)
        .padding(.horizontal, 30)
    }
    
    // MARK: - Enterprise Login View
    private func enterpriseLoginView() -> some View {
        VStack(spacing: 20) {
            Text("CONNEXION ENTREPRISE")
                .font(.custom("Avenir-Heavy", size: 15))
                .tracking(1)
                .foregroundColor(Color.gray.opacity(0.8))
                .padding(.bottom, 15)
            
            ProfessionalTextField(
                placeholder: "Email",
                text: $email,
                icon: "envelope"
            )
            
            ProfessionalTextField(
                placeholder: "Mot de passe",
                text: $password,
                icon: "lock",
                isSecure: true
            )
            
            // Error message if login failed
            if let error = authenticationError {
                Text(error)
                    .font(.custom("Avenir-Medium", size: 14))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Login button with loading state
            if isAuthenticating {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: accentColor))
                    .scaleEffect(1.5)
                    .padding(.top, 10)
            } else {
                ProfessionalButton(
                    title: "SE CONNECTER",
                    icon: "arrow.right.circle",
                    color: accentColor,
                    action: {
                        enterpriseLogin()
                    }
                )
                .padding(.top, 10)
            }
            
            // Back Button
            ProfessionalBackButton {
                withAnimation(springAnimation) {
                    email = ""
                    password = ""
                    authenticationError = nil
                    currentView = "loginOptions"
                }
            }
        }
        .frame(maxWidth: 360)
        .padding(.horizontal, 30)
    }
    
    // MARK: - Enterprise Registration View
    private func enterpriseRegistrationView() -> some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("INSCRIPTION ENTREPRISE")
                    .font(.custom("Avenir-Heavy", size: 15))
                    .tracking(1)
                    .foregroundColor(Color.gray.opacity(0.8))
                    .padding(.bottom, 15)
                
                ProfessionalTextField(
                    placeholder: "Nom de l'entreprise",
                    text: $companyName,
                    icon: "building.2"
                )
                
                ProfessionalTextField(
                    placeholder: "Email professionnel",
                    text: $email,
                    icon: "envelope"
                )
                
                ProfessionalTextField(
                    placeholder: "Numéro de téléphone",
                    text: $phoneNumber,
                    icon: "phone"
                )
                
                ProfessionalTextField(
                    placeholder: "Mot de passe",
                    text: $password,
                    icon: "lock",
                    isSecure: true
                )
                
                // Error message if registration failed
                if let error = authenticationError {
                    Text(error)
                        .font(.custom("Avenir-Medium", size: 14))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Register button with loading state
                if isAuthenticating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: accentColor))
                        .scaleEffect(1.5)
                        .padding(.top, 10)
                } else {
                    ProfessionalButton(
                        title: "S'INSCRIRE",
                        icon: "checkmark.circle",
                        color: accentColor,
                        action: {
                            enterpriseRegister()
                        }
                    )
                    .padding(.top, 10)
                }
                
                // Back Button
                ProfessionalBackButton {
                    withAnimation(springAnimation) {
                        companyName = ""
                        email = ""
                        phoneNumber = ""
                        password = ""
                        authenticationError = nil
                        currentView = "loginOptions"
                    }
                }
            }
            .frame(maxWidth: 360)
            .padding(.horizontal, 30)
        }
    }
    
    // MARK: - Features Section
    private func featuresSection() -> some View {
        VStack(spacing: 40) {
            Text("NOS SERVICES")
                .font(.custom("Avenir-Heavy", size: 22))
                .tracking(1)
                .foregroundColor(textColor)
                .padding(.bottom, 10)
            
            // Features grid
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 280))], spacing: 25) {
                FeatureCard(
                    icon: "iPhone.homebutton",
                    title: "Réparation iPhone & iPad",
                    description: "Diagnostic professionnel et réparation de qualité pour vos appareils Apple."
                )
                
                FeatureCard(
                    icon: "display.2",
                    title: "Service Express",
                    description: "Réparation rapide en moins de 30 minutes pour les problèmes courants."
                )
                
                FeatureCard(
                    icon: "building.2.crop.circle",
                    title: "Solutions Entreprise",
                    description: "Services dédiés aux professionnels avec support prioritaire et tarifs spéciaux."
                )
                
                FeatureCard(
                    icon: "checkmark.shield",
                    title: "Garantie 12 Mois",
                    description: "Toutes nos réparations sont garanties pour votre tranquillité d'esprit."
                )
            }
            .padding(.horizontal, 20)
        }
    }
    
    // Feature card component
    private func FeatureCard(icon: String, title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 15) {
                // Icon container
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(accentColor)
                }
                
                Text(title)
                    .font(.custom("Avenir-Heavy", size: 17))
                    .foregroundColor(textColor)
            }
            
            Text(description)
                .font(.custom("Avenir-Medium", size: 15))
                .foregroundColor(Color.gray.opacity(0.9))
                .lineSpacing(4)
                .padding(.leading, 63)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Footer View
    private func footerView() -> some View {
        VStack(spacing: 15) {
            Divider()
                .background(Color.gray.opacity(0.3))
                .padding(.horizontal, 40)
                .padding(.bottom, 10)
            
            Text("© 2025 PHONNE ADDICT • Tous droits réservés")
                .font(.custom("Avenir-Medium", size: 13))
                .foregroundColor(Color.gray.opacity(0.6))
        }
    }
    
    // MARK: - Authentication Functions
    
    // Enterprise login
    private func enterpriseLogin() {
        // Validation
        guard !email.isEmpty, !password.isEmpty else {
            authenticationError = "Veuillez remplir tous les champs"
            return
        }
        
        isAuthenticating = true
        authenticationError = nil
        
        databaseService.signIn(email: email, password: password) { result in
            DispatchQueue.main.async {
                self.isAuthenticating = false
                
                switch result {
                case .success(let user):
                    if user.isAdmin {
                        // Si admin, rediriger vers l'accès administrateur
                        self.authenticationError = "Ce compte est un compte administrateur, veuillez utiliser l'accès administrateur"
                    } else {
                        // Si entreprise, rediriger vers la vue principale entreprise
                        print("Connexion entreprise réussie: \(user.email)")
                        withAnimation {
                            self.showEnterpriseMainView = true
                        }
                    }
                case .failure(let error):
                    // Gestion des erreurs d'authentification Firebase avec messages personnalisés
                    if let authError = error as NSError?, authError.domain == "FIRAuthErrorDomain" {
                        switch authError.code {
                        case 17009: // wrong password
                            self.authenticationError = "Mot de passe incorrect"
                        case 17011: // user not found
                            self.authenticationError = "Aucun compte trouvé avec cet email"
                        case 17008: // invalid email
                            self.authenticationError = "Format d'email invalide"
                        case 17010: // too many requests
                            self.authenticationError = "Trop de tentatives échouées, veuillez réessayer plus tard"
                        default:
                            self.authenticationError = "Erreur d'authentification: \(error.localizedDescription)"
                        }
                    } else {
                        self.authenticationError = "Erreur d'authentification: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    // Admin login
    private func adminLogin() {
        // Validation
        guard !adminEmail.isEmpty, !adminPassword.isEmpty else {
            authenticationError = "Veuillez remplir tous les champs"
            return
        }
        
        isAuthenticating = true
        authenticationError = nil
        
        // Utiliser un délai pour éviter toute action trop rapide qui pourrait causer un crash
        print("Tentative de connexion admin avec: \(adminEmail)")
        
        databaseService.signIn(email: adminEmail, password: adminPassword) { result in
            DispatchQueue.main.async {
                self.isAuthenticating = false
                
                switch result {
                case .success(let user):
                    print("Connexion réussie, vérification des privilèges admin. isAdmin = \(user.isAdmin)")
                    
                    if user.isAdmin {
                        // Si c'est un admin, rediriger vers la vue admin avec un léger délai
                        print("Connexion administrateur réussie: \(user.email)")
                        
                        // Utiliser un délai pour s'assurer que toutes les opérations UI précédentes sont terminées
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            print("Navigation vers AdminMainView...")
                            self.navigateToAdmin = true
                        }
                    } else {
                        // Si ce n'est pas un admin, afficher un message d'erreur
                        print("Utilisateur non-admin essayant de se connecter comme admin")
                        self.authenticationError = "Ce compte n'a pas les privilèges administrateur"
                    }
                case .failure(let error):
                    print("Erreur de connexion: \(error.localizedDescription)")
                    
                    // Gestion des erreurs d'authentification Firebase avec messages personnalisés
                    if let authError = error as NSError?, authError.domain == "FIRAuthErrorDomain" {
                        switch authError.code {
                        case 17009: // wrong password
                            self.authenticationError = "Mot de passe incorrect"
                        case 17011: // user not found
                            self.authenticationError = "Aucun compte trouvé avec cet email"
                        case 17008: // invalid email
                            self.authenticationError = "Format d'email invalide"
                        case 17010: // too many requests
                            self.authenticationError = "Trop de tentatives échouées, veuillez réessayer plus tard"
                        default:
                            self.authenticationError = "Erreur d'authentification: \(error.localizedDescription)"
                        }
                    } else {
                        self.authenticationError = "Erreur d'authentification: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    // Enterprise registration
    private func enterpriseRegister() {
        // Validation
        guard !companyName.isEmpty, !email.isEmpty, !phoneNumber.isEmpty, !password.isEmpty else {
            authenticationError = "Veuillez remplir tous les champs"
            return
        }
        
        // Password validation
        if password.count < 6 {
            authenticationError = "Le mot de passe doit contenir au moins 6 caractères"
            return
        }
        
        isAuthenticating = true
        authenticationError = nil
        
        databaseService.signUp(email: email, password: password, companyName: companyName, phoneNumber: phoneNumber) { result in
            DispatchQueue.main.async {
                self.isAuthenticating = false
                
                switch result {
                case .success(let user):
                    print("Inscription entreprise réussie: \(user.email)")
                    withAnimation {
                        self.showEnterpriseMainView = true
                    }
                case .failure(let error):
                    // Gestion des erreurs d'authentification Firebase avec messages personnalisés
                    if let authError = error as NSError?, authError.domain == "FIRAuthErrorDomain" {
                        switch authError.code {
                        case 17007: // email already in use
                            self.authenticationError = "Cet email est déjà utilisé par un autre compte"
                        case 17008: // invalid email
                            self.authenticationError = "Format d'email invalide"
                        case 17026: // weak password
                            self.authenticationError = "Le mot de passe est trop faible"
                        default:
                            self.authenticationError = "Erreur d'inscription: \(error.localizedDescription)"
                        }
                    } else {
                        self.authenticationError = "Erreur d'inscription: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    // MARK: - Animations
    
    // Start all animations
    private func startAnimations() {
        // Animate background
        withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            animateBackground = true
        }
        
        // Animate the title opacity
        withAnimation(Animation.easeIn(duration: 0.8)) {
            titleOpacity = 1
        }
        
        // Start typing animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            startTypingAnimation()
        }
        
        // Animate buttons after typing animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(Animation.easeIn(duration: 0.6)) {
                contentOpacity = 1
            }
        }
    }
    
    // Typing animation for subtitle with dynamic timing
    private func startTypingAnimation() {
        typingIndex = 0
        typingText = ""
        
        func addNextCharacter() {
            if typingIndex < fullText.count {
                let nextChar = fullText[fullText.index(fullText.startIndex, offsetBy: typingIndex)]
                typingText.append(nextChar)
                typingIndex += 1
                
                // Slightly variable timing for more natural typing
                let delay = nextChar == " " ? 0.07 : Double.random(in: 0.03...0.06)
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    addNextCharacter()
                }
            }
        }
        
        addNextCharacter()
    }
}

// MARK: - Professional Buttons
struct ProfessionalButton: View {
    let title: String
    let icon: String
    let color: Color
    var iconColor: Color? = nil
    let action: () -> Void
    @State private var isPressed = false
    @State private var isHovered = false
    
    var body: some View {
        Button(action: {
            hapticFeedback()
            isPressed = true
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = false
            }
            action()
        }) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(iconColor ?? Color.white)
                    .padding(.trailing, 12)
                Text(title)
                    .font(.custom("Avenir-Heavy", size: 15))
                    .tracking(0.8)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.7))
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                ZStack {
                    // Base color with subtle gradient
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    color.opacity(0.9),
                                    color.opacity(0.8)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: color.opacity(0.25), radius: 10, x: 0, y: 5)
                    
                    // Top highlight
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.07),
                                    Color.white.opacity(0)
                                ]),
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                    
                    // Border
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.12),
                                    Color.white.opacity(0.05)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                }
            )
            .scaleEffect(isPressed ? 0.985 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = hovering
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

// MARK: - Back Button
struct ProfessionalBackButton: View {
    let action: () -> Void
    @State private var isHovered = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            isPressed = true
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = false
            }
            action()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .medium))
                    .offset(x: isHovered ? -2 : 0)
                
                Text("RETOUR")
                    .font(.custom("Avenir-Medium", size: 14))
                    .tracking(0.5)
            }
            .foregroundColor(Color.white.opacity(isHovered ? 0.9 : 0.7))
            .padding(.vertical, 10)
            .padding(.horizontal, 5)
            .background(Color.clear)
            .contentShape(Rectangle())
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .scaleEffect(isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .onHover { hovering in
                withAnimation {
                    isHovered = hovering
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.top, 15)
    }
}

// MARK: - Text Field Component
struct ProfessionalTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    var isSecure: Bool = false
    @State private var isFocused = false
    @State private var showPassword = false
    
    var accentColor = Color(red: 255/255, green: 96/255, blue: 0/255)
    
    var body: some View {
        VStack {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .foregroundColor(isFocused ? accentColor : Color.gray.opacity(0.7))
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 20)
                
                if isSecure && !showPassword {
                    SecureField(placeholder, text: $text)
                        .font(.custom("Avenir-Medium", size: 15))
                        .foregroundColor(Color.white.opacity(0.9))
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.2)) {
                                isFocused = true
                            }
                        }
                } else {
                    TextField(placeholder, text: $text)
                        .font(.custom("Avenir-Medium", size: 15))
                        .foregroundColor(Color.white.opacity(0.9))
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.2)) {
                                isFocused = true
                            }
                        }
                }
                
                if isSecure {
                    Button(action: {
                        withAnimation {
                            showPassword.toggle()
                        }
                    }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray.opacity(0.7))
                            .frame(width: 20)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 20/255, green: 20/255, blue: 24/255))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                isFocused ? accentColor.opacity(0.5) : Color.gray.opacity(0.2),
                                lineWidth: 1
                            )
                    )
            )
            .onChange(of: text) { _ in
                isFocused = true
            }
        }
    }
}

// MARK: - Background Effects
struct GridPatternView: View {
    let lineSpacing: CGFloat = 24
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                // Draw vertical lines
                for x in stride(from: 0, to: size.width, by: lineSpacing) {
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    context.stroke(path, with: .color(Color.white), lineWidth: 0.2)
                }
                
                // Draw horizontal lines
                for y in stride(from: 0, to: size.height, by: lineSpacing) {
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    context.stroke(path, with: .color(Color.white), lineWidth: 0.2)
                }
            }
        }
    }
}

// Circuit Pattern View
struct CircuitPatternView: View {
    @Binding var animate: Bool
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                // Circuit nodes
                let nodeCount = 65
                let nodeSizes: [CGFloat] = [2, 3, 4, 5]
                let accentColor = Color(red: 255/255, green: 96/255, blue: 0/255)
                
                for i in 0..<nodeCount {
                    let x = CGFloat.random(in: 0...size.width)
                    let y = CGFloat.random(in: 0...size.height)
                    let nodeSize = nodeSizes.randomElement() ?? 3
                    
                    // Subtle pulse effect
                    let timeOffset = Double(i) * 0.04
                    let pulsePhase = sin((timeline.date.timeIntervalSinceReferenceDate + timeOffset).truncatingRemainder(dividingBy: 3) * .pi)
                    let pulseScale = 1.0 + (animate ? pulsePhase * 0.2 : 0)
                    
                    // Draw node (dot)
                    let isAccent = i % 15 == 0
                    let nodeColor = isAccent ? accentColor : Color.white
                    let nodeOpacity = isAccent ? 0.6 : 0.25
                    
                    context.opacity = nodeOpacity
                    let nodePath = Path(ellipseIn: CGRect(
                        x: x - nodeSize * pulseScale / 2,
                        y: y - nodeSize * pulseScale / 2,
                        width: nodeSize * pulseScale,
                        height: nodeSize * pulseScale
                    ))
                    
                    context.fill(nodePath, with: .color(nodeColor))
                    
                    // Draw connecting lines between some nodes
                    if i > 0 && i % 3 == 0 {
                        let prevX = CGFloat.random(in: max(0, x - 100)...min(size.width, x + 100))
                        let prevY = CGFloat.random(in: max(0, y - 100)...min(size.height, y + 100))
                        
                        var linePath = Path()
                        linePath.move(to: CGPoint(x: x, y: y))
                        
                        // Some lines have slight curves
                        if i % 5 == 0 {
                            let controlX = (x + prevX) / 2 + CGFloat.random(in: -15...15)
                            let controlY = (y + prevY) / 2 + CGFloat.random(in: -15...15)
                            linePath.addQuadCurve(to: CGPoint(x: prevX, y: prevY),
                                               control: CGPoint(x: controlX, y: controlY))
                        } else {
                            linePath.addLine(to: CGPoint(x: prevX, y: prevY))
                        }
                        
                        context.stroke(linePath, with: .color(nodeColor.opacity(0.1)), lineWidth: 0.5)
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .environmentObject(DatabaseService())
    }
}
