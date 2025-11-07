//
//  LearningCardModel.swift
//  LearnOnTheGo
//
//  Created by Surya Teja Nammi on 11/5/25.
//

import Foundation

// Model now conforms to Codable and data is loaded from JSON
struct LearningCardModel: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    let description: String
    let imageName: String
    let learnCards: [LearnCard]
    
    var cardProgress: Int {
        learnCards.filter(\.self.isViewed).count
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct LearnCard: Hashable, Codable {
    let title: String
    let content: String
    var isViewed: Bool

    mutating func updateView(_ value: Bool) {
        isViewed = value
    }
}

struct LearningCardProgressModel {
    var learnCard: LearnCard
    let currentIndex: Int
    let totalCount: Int
    let title: String
}

struct LearningCardDataLoader {
    static func load(fromFile fileName: String = "learning_cards", withExtension ext: String = "json") -> [LearningCardModel] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: ext) else {
            #if DEBUG
            print("[LearningCardDataLoader] Missing JSON resource: \(fileName).\(ext)")
            #endif
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            return try decoder.decode([LearningCardModel].self, from: data)
        } catch {
            #if DEBUG
            print("[LearningCardDataLoader] Failed to decode JSON: \(error)")
            #endif
            return []
        }
    }
}


// MARK: - Card Model
struct ExploreCard: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let learnCards: [LearnCard]

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case imageName
        case learnCard
    }

    init(title: String, description: String, imageName: String, learnCards: [LearnCard] = []) {
        self.title = title
        self.description = description
        self.imageName = imageName
        self.learnCards = learnCards
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.imageName = try container.decode(String.self, forKey: .imageName)
        self.learnCards = try container.decodeIfPresent([LearnCard].self, forKey: .learnCard) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(imageName, forKey: .imageName)
        if !learnCards.isEmpty {
            try container.encode(learnCards, forKey: .learnCard)
        }
    }
}

// MARK: - Learning Cards Container
struct ExploreLearningCardsData: Codable {
    let resumeLearning: [ExploreCard]
    let bookmarked: [ExploreCard]
    let topics: [ExploreCard]

    enum CodingKeys: String, CodingKey {
        case resumeLearning = "resumeLearning"
        case bookmarked = "Bookmarked"
        case topics = "Topics"
    }
}

// MARK: - Sample Data
extension ExploreLearningCardsData {
    static let sample = ExploreLearningCardsData(
        resumeLearning: [
            ExploreCard(title: "Generative AI & LLMs", description: "Understand how LLMs generate new content", imageName: "GenAI", learnCards: genAIAndMLCards),
            ExploreCard(title: "Microservices & Architecture", description: "Learn about the principles and best practices of microservices architecture", imageName: "microservices", learnCards: microservicesLearnCards)
        ],
        bookmarked: [
            ExploreCard(title: "Data warehouse", description: "Build Reliable Infrastructure", imageName: "DataWarehouse", learnCards: dataWarehousingCards),
            ExploreCard(title: "Cloud Banking", description: "Build Reliable Infrastructure", imageName: "CloudBanking", learnCards: cloudBankingCards),
        ],
        topics: [
            ExploreCard(title: "Microservices & Architecture", description: "Learn about the principles and best practices of microservices architecture", imageName: "microservices", learnCards: microservicesLearnCards),
            ExploreCard(title: "Generative AI & LLMs", description: "Understand how LLMs generate new content", imageName: "GenAI", learnCards: genAIAndMLCards),
            ExploreCard(title: "Cloud Banking", description: "Learn about the latest trends in cloud banking and financial services.", imageName: "CloudBanking", learnCards: cloudBankingCards),
            ExploreCard(title: "Data warehouse", description: "Data warehousing involves storing, managing, and analyzing large volumes of data", imageName: "DataWarehouse", learnCards: dataWarehousingCards),
            ExploreCard(title: "Open Shift", description: "Learn about the latest trends in cloud banking and financial services.", imageName: "Laptop", learnCards: openShiftCards),
        ]
    )
    static let operationsDataSample = ExploreLearningCardsData(
        resumeLearning: [
            ExploreCard(title: "Credit card Operations", description: "Learn about credit card processing", imageName: "CreditCard", learnCards: creditCardOperationsCards),
            ExploreCard(title: "Transaction Fraud", description: "Understand how to shield from fraud", imageName: "Transactionfraud", learnCards: transactionFraudCards)
        ],
        bookmarked: [
            ExploreCard(title: "Loan processing", description: "Build Reliable Infrastructure", imageName: "LoanProcessing", learnCards: loanProcessingCards),
            ExploreCard(title: "Customer onboarding", description: "Build Reliable Infrastructure", imageName: "CustomerOnboard", learnCards: customerOnboardingCards),
        ],
        topics: [
            ExploreCard(title: "KYC Processing", description: "Know your customer", imageName: "KYC", learnCards: kycCards),
            ExploreCard(title: "Transaction Fraud", description: "Understand how to shield from fraud", imageName: "Transactionfraud", learnCards: transactionFraudCards),
            ExploreCard(title: "Credit Card Operations", description: "Learn about credit card processing", imageName: "CreditCard", learnCards: creditCardOperationsCards),
            ExploreCard(title: "Loan processing", description: "Learn how your loan process", imageName: "LoanProcessing", learnCards: loanProcessingCards),
            ExploreCard(title: "Customer Onboarding", description: "Learn how a new customer is onboarded into financial services", imageName: "CustomerOnboard", learnCards: customerOnboardingCards),
        ]
    )
}
    
extension ExploreLearningCardsData {
    // MARK: Technical cards
    static let microservicesLearnCards: [LearnCard] = [
        LearnCard(
            title: "What Are Microservices?",
            content: "Microservice architecture structures an application as a collection of small, independent services, each focused on a specific business capability. These services communicate over APIs and can be developed, deployed, and scaled independently. This approach contrasts with monolithic architectures, where all functionality is tightly integrated.",
            isViewed: false
        ),
        LearnCard(
            title: "Monolithic vs. Microservices",
            content: "Monolithic applications bundle all features into a single codebase, making updates and scaling challenging. Microservices break down functionality into discrete, loosely coupled units, enabling teams to work on, deploy, and scale services independently. This separation improves agility and resilience.",
            isViewed: false
        ),
        LearnCard(
            title: "Key Characteristics",
            content: "Microservices are autonomous, loosely coupled, and independently deployable. Each service owns its data and technology stack, allowing teams to choose the best tools for their needs. Services interact through well-defined APIs, often using REST or messaging protocols.",
            isViewed: false
        ),
        LearnCard(
            title: "Benefits of Microservices",
            content: "Microservices offer agility, flexible scaling, and faster time-to-market. Teams can update or scale individual services without affecting the entire application. This architecture also enhances fault isolation, so failures in one service do not bring down the whole system.",
            isViewed: false
        ),
        LearnCard(
            title: "Deployment and Agility",
            content: "Microservices enable continuous integration and delivery practices. Teams can deploy updates or roll back changes for individual services quickly, reducing risk and accelerating innovation. This supports frequent releases and rapid response to business needs.",
            isViewed: false
        ),
        LearnCard(
            title: "Technology Diversity",
            content: "Teams are free to select the most suitable programming languages, frameworks, and databases for each microservice. This flexibility allows organizations to leverage the best tools for each problem and evolve technology stacks over time without disrupting the entire system.",
            isViewed: false
        )
    ]
    
    static let genAIAndMLCards: [LearnCard] = [
        LearnCard(
            title: "Topic: GENAI and ML",
            content: "Overview: GENAI & ML\nGenerative AI (GENAI) and Machine Learning (ML) are transformative technologies in artificial intelligence. GENAI focuses on creating new content, while ML analyzes data to make predictions or decisions. Understanding their differences is key to leveraging their strengths in modern applications.",
            isViewed: false
        ),
        LearnCard(
            title: "What Is Machine Learning?",
            content: "Machine Learning enables computers to learn patterns from data and improve their performance over time. It uses algorithms to classify, predict, or optimize outcomes based on historical data. ML is widely used for tasks like fraud detection, recommendation systems, and process automation.",
            isViewed: false
        ),
        LearnCard(
            title: "What Is Generative AI?",
            content: "Generative AI creates new data, such as text, images, or music, by learning patterns from existing datasets. Unlike traditional ML, GENAI can produce original outputs that mimic human creativity. Applications include chatbots, image synthesis, and content generation.",
            isViewed: false
        ),
        LearnCard(
            title: "Core Differences",
            content: "GENAI specializes in generating novel content, while ML excels at analyzing and predicting based on existing data. GENAI often uses unsupervised learning, whereas ML employs supervised, unsupervised, or reinforcement learning. Their distinct approaches shape their use cases and data requirements.",
            isViewed: false
        ),
        LearnCard(
            title: "Learning Approaches",
            content: "Machine Learning relies on labeled datasets for supervised learning, or unlabeled data for unsupervised learning. Generative AI typically leverages unsupervised or semi-supervised methods, focusing on understanding data structure to generate new samples. The choice of approach impacts model performance and data preparation.",
            isViewed: false
        ),
        LearnCard(
            title: "Business Applications",
            content: "GENAI is ideal for creative tasks such as generating marketing content, designing images, or automating writing. ML is better suited for analytical tasks like forecasting, customer segmentation, and anomaly detection. Integrating both can optimize workflows and enhance productivity across industries.",
            isViewed: false
        ),
        LearnCard(
            title: "Challenges & Considerations",
            content: "Both GENAI and ML require high-quality data and robust model evaluation. GENAI may introduce risks like bias or misinformation in generated content, while ML models can suffer from overfitting or poor generalization. Careful data handling and monitoring are essential for reliable outcomes.",
            isViewed: false
        ),
        LearnCard(
            title: "Recent Advances",
            content: "Recent breakthroughs include large language models (LLMs) and advanced neural networks powering GENAI, and automated ML pipelines for scalable deployment. These innovations have accelerated adoption in sectors like healthcare, finance, and entertainment, driving new possibilities for automation and creativity.",
            isViewed: false
        ),
        LearnCard(
            title: "Best Practices",
            content: "Successful implementation involves clear problem definition, careful data selection, and ongoing model evaluation. Combining GENAI and ML can unlock synergies, but requires attention to ethical considerations, transparency, and continuous improvement to maximize value and minimize risks.",
            isViewed: false
        ),
        LearnCard(
            title: "Further Learning & Documentation",
            content: "Explore official resources for deeper understanding:",
            isViewed: false
        )
    ]
    
    static let cloudBankingCards: [LearnCard] = [
        LearnCard(
            title: "Topic: Cloud Platforms for Banking",
            content: "Cloud Banking Overview\nCloud platforms in banking involve using cloud computing to host core banking systems, applications, and data. This enables banks to increase agility, reduce costs, and innovate rapidly. Cloud adoption is transforming how financial services are delivered and managed, making operations more efficient and future-ready.",
            isViewed: false
        ),
        LearnCard(
            title: "Key Drivers for Adoption",
            content: "Banks are adopting cloud platforms to improve scalability, accelerate product launches, and enhance customer experiences. The demand for digital transformation, cost efficiency, and regulatory compliance are major motivators. Cloud also enables banks to respond quickly to market changes and evolving customer needs.",
            isViewed: false
        ),
        LearnCard(
            title: "Core Benefits for Banks",
            content: "Cloud platforms offer banks benefits such as lower infrastructure costs, high availability, and rapid disaster recovery. They support business continuity, provide access to advanced analytics, and enable usage-based payment models. These advantages help banks remain competitive and resilient in a dynamic market.",
            isViewed: false
        ),
        LearnCard(
            title: "Cloud Service Models",
            content: "Banks utilize various cloud service models: Infrastructure as a Service (IaaS) for flexible computing resources, Platform as a Service (PaaS) for rapid app development, and Software as a Service (SaaS) for ready-to-use banking applications. Each model offers different levels of control and customization.",
            isViewed: false
        ),
        LearnCard(
            title: "Security and Compliance",
            content: "Security is a top concern in cloud banking due to the sensitive nature of financial data. Cloud providers offer robust security features, including encryption, identity management, and compliance certifications. Banks must ensure that cloud solutions meet regulatory requirements and protect customer data.",
            isViewed: false
        ),
        LearnCard(
            title: "Disaster Recovery & Continuity",
            content: "Cloud platforms enhance disaster recovery by providing automated backups, geographic redundancy, and rapid failover capabilities. This ensures that banking services remain available even during unexpected disruptions, supporting regulatory mandates for business continuity and minimizing downtime.",
            isViewed: false
        ),
        LearnCard(
            title: "Innovation and Agility",
            content: "Cloud enables banks to innovate faster by leveraging AI, machine learning, and real-time analytics. New products and services can be developed and deployed quickly, allowing banks to stay ahead of competitors and better meet customer expectations in a digital-first world.",
            isViewed: false
        ),
        LearnCard(
            title: "Challenges and Considerations",
            content: "Despite its benefits, cloud adoption in banking faces challenges such as data sovereignty, integration with legacy systems, and evolving security threats. Banks must carefully plan migration strategies, manage risks, and ensure continuous compliance with industry regulations.",
            isViewed: false
        ),
        LearnCard(
            title: "Future Trends in Cloud Banking",
            content: "The future of cloud banking includes greater use of AI-driven analytics, industry-specific cloud solutions, and increased collaboration between banks and fintechs. As regulatory frameworks mature, cloud adoption will accelerate, driving further innovation and operational efficiency.",
            isViewed: false
        )
    ]
    
    static let dataWarehousingCards: [LearnCard] = [
        LearnCard(
            title: "Topic: Data Warehousing and Business Analytics",
            content: "Introduction to Data Warehousing\nData warehousing is the process of collecting, integrating, and managing data from diverse sources to provide a unified, historical view for analysis. It supports business intelligence by enabling organizations to make informed, data-driven decisions. Data warehouses are optimized for complex queries and analytics, not for transaction processing.",
            isViewed: false
        ),
        LearnCard(
            title: "Key Components of a Data Warehouse",
            content: "A typical data warehouse includes source data, ETL (Extract, Transform, Load) processes, storage models, and analytical tools. Data is extracted from operational systems, transformed for consistency, and loaded into structured storage. Analytical tools then enable users to query and visualize the data for insights.",
            isViewed: false
        ),
        LearnCard(
            title: "Data Warehousing vs. OLTP",
            content: "Unlike Online Transaction Processing (OLTP) systems, which handle day-to-day operations, data warehouses are designed for analytical processing. They store aggregated, non-volatile, and historical data, optimized for queries rather than frequent updates. This distinction enables efficient trend analysis and strategic decision-making.",
            isViewed: false
        ),
        LearnCard(
            title: "Data Modeling Techniques",
            content: "Data warehouses use structured models like star and snowflake schemas to organize information. These models define relationships between facts and business dimensions such as time, product, or geography, making data intuitive to query and analyze. Proper modeling enhances performance and user accessibility.",
            isViewed: false
        ),
        LearnCard(
            title: "ETL: Extract, Transform, Load",
            content: "ETL processes are essential for integrating data from multiple sources. Extraction gathers raw data, transformation ensures consistency and quality, and loading moves the processed data into the warehouse. Effective ETL guarantees reliable, accurate data for business analytics.",
            isViewed: false
        ),
        LearnCard(
            title: "Business Analytics Fundamentals",
            content: "Business analytics leverages data warehouses to uncover patterns, trends, and insights. Analytical tools enable users to perform ad hoc queries, generate reports, and visualize data. This empowers organizations to make evidence-based decisions and measure performance against key metrics.",
            isViewed: false
        ),
        LearnCard(
            title: "Advanced Analytics and BI",
            content: "Modern data warehouses support advanced analytics, including predictive modeling, data mining, and tactical analysis. Business intelligence platforms provide dashboards and interactive reports, helping users explore data at various levels of detail and forecast future outcomes.",
            isViewed: false
        ),
        LearnCard(
            title: "Cloud Data Warehousing Trends",
            content: "Cloud-based data warehouses offer scalability, flexibility, and cost efficiency. Solutions like Amazon Redshift and Snowflake enable organizations to handle large and complex datasets, support real-time analytics, and integrate seamlessly with modern BI tools. Cloud adoption is accelerating data-driven transformation.",
            isViewed: false
        ),
        LearnCard(
            title: "Best Practices & Challenges",
            content: "Effective data warehousing requires robust metadata management, data governance, and performance optimization. Challenges include ensuring data quality, managing security, and scaling with growing data volumes. Adopting best practices ensures reliable analytics and regulatory compliance.",
            isViewed: false
        )
    ]
    
    static let openShiftCards: [LearnCard] = [
        LearnCard(
            title: "Topic: OpenShift",
            content: "OpenShift Overview\nOpenShift is Red Hat’s enterprise Kubernetes platform for building, deploying, and managing containerized applications at scale. It provides a consistent cloud-like experience across public, private, and hybrid infrastructure. OpenShift streamlines development and operations, enabling rapid innovation and secure, automated workflows.",
            isViewed: false
        ),
        LearnCard(
            title: "Core Architecture",
            content: "OpenShift architecture consists of master and worker nodes. Master nodes handle cluster management, API requests, authentication, scheduling, and health checks, while worker nodes run application workloads. This layered design supports scalability, reliability, and efficient resource utilization.",
            isViewed: false
        ),
        LearnCard(
            title: "Kubernetes Integration",
            content: "OpenShift is built on Kubernetes, extending its capabilities with enhanced security, developer tools, and enterprise features. It automates container orchestration, networking, and lifecycle management, providing a robust foundation for cloud-native applications.",
            isViewed: false
        ),
        LearnCard(
            title: "Developer Experience",
            content: "OpenShift offers a responsive web console and powerful CLI tools, allowing developers to build, test, and deploy applications efficiently. Integrated CI/CD pipelines and source-to-image workflows accelerate development cycles and improve code quality.",
            isViewed: false
        ),
        LearnCard(
            title: "Security Features",
            content: "Security is central to OpenShift, with built-in authentication, role-based access control, and encrypted communication. It enforces strict container isolation and provides automated vulnerability scanning to safeguard applications and data.",
            isViewed: false
        ),
        LearnCard(
            title: "Hybrid Cloud Flexibility",
            content: "OpenShift supports deployment on-premises, in public clouds, or across hybrid environments. Its unified platform enables organizations to manage virtual machines and containers in parallel, reducing operational complexity and increasing agility.",
            isViewed: false
        ),
        LearnCard(
            title: "Automated Operations",
            content: "OpenShift automates cluster installation, upgrades, scaling, and health monitoring. Built-in logging and monitoring tools provide visibility into application performance, while self-healing mechanisms ensure high availability and resilience.",
            isViewed: false
        ),
        LearnCard(
            title: "Enterprise Capabilities",
            content: "OpenShift delivers enterprise-grade features such as backup and recovery, multi-cluster management, and integrated service mesh. These capabilities support large-scale deployments and complex application architectures, meeting the needs of modern organizations.",
            isViewed: false
        ),
        LearnCard(
            title: "Use Cases",
            content: "OpenShift is used for microservices, AI/ML workloads, legacy modernization, and DevOps automation. Its flexibility and scalability make it suitable for diverse industries, from finance to healthcare, enabling rapid digital transformation.",
            isViewed: false
        )
    ]
}


extension ExploreLearningCardsData {
    // MARK: Operations cards
        static let kycCards: [LearnCard] = [
            LearnCard(
                title: "Topic: KYC",
                content: "KYC: Strategic Overview\nKYC is a regulatory cornerstone in banking, requiring institutions to verify client identities, assess risk profiles, and monitor for suspicious activity. Its evolution responds to global threats like money laundering and terrorism, shaping compliance frameworks and operational priorities.",
                isViewed: false
            ),
            LearnCard(
                title: "Regulatory Drivers & Evolution",
                content: "KYC regulations stem from the Bank Secrecy Act and were strengthened by the USA PATRIOT Act. Recent updates reflect increased scrutiny post-financial crises and ongoing adaptation to new financial crime trends, demanding continuous process enhancements.",
                isViewed: false
            ),
            LearnCard(
                title: "Core KYC Processes",
                content: "KYC involves onboarding due diligence, ongoing transaction monitoring, and periodic reviews. Practical scenarios include verifying directors for corporate accounts, updating customer profiles after major life events, and flagging unusual transaction patterns for investigation.",
                isViewed: false
            ),
            LearnCard(
                title: "Risk-Based Approach in Practice",
                content: "Banks assign risk ratings based on customer profiles and transaction behaviors. High-risk clients, such as politically exposed persons or those with complex ownership structures, trigger enhanced due diligence, including deeper document checks and source-of-funds analysis.",
                isViewed: false
            ),
            LearnCard(
                title: "Continuous Profiling & Perpetual KYC",
                content: "KYC is not a one-time event; banks must continuously update customer data and monitor for behavioral changes. Real-time alerts for deviations from typical patterns, such as sudden international transfers, prompt immediate review and risk reassessment.",
                isViewed: false
            ),
            LearnCard(
                title: "Document Verification Challenges",
                content: "Verifying identity documents can be complex, especially with remote onboarding or international clients. Scenarios include detecting forged passports, validating utility bills, and leveraging biometric verification to reduce fraud risk while maintaining customer experience.",
                isViewed: false
            ),
            LearnCard(
                title: "KYC for Corporate Clients",
                content: "Corporate KYC requires identifying beneficial owners, verifying business registration, and assessing operational legitimacy. Practical issues include handling layered ownership structures and cross-border entities, often necessitating collaboration with compliance and legal teams.",
                isViewed: false
            ),
            LearnCard(
                title: "Technology & Automation Trends",
                content: "Banks increasingly deploy AI and machine learning to automate KYC checks, flag anomalies, and streamline onboarding. Scenario-driven automation reduces manual errors and accelerates compliance, but requires robust data governance and regular model validation.",
                isViewed: false
            ),
            LearnCard(
                title: "Common Pitfalls & Remediation",
                content: "Operational challenges include incomplete data capture, outdated customer profiles, and inconsistent risk assessments. Remediation strategies involve regular staff training, audit trails for KYC decisions, and proactive engagement with customers to update records.",
                isViewed: false
            ),
            LearnCard(
                title: "Further Learning & Documentation",
                content: "Next steps: Explore AML, CDD, and EDD concepts. Review official guidance from regulators. Recommended links:\n\nFinCEN KYC Resource\nFATF KYC Guidance\nSWIFT KYC Registry",
                isViewed: false
            )
        ]

        static let transactionFraudCards: [LearnCard] = [
            LearnCard(
                title: "Topic: Transaction and Fraud Detection",
                content: "Transaction Lifecycle & Fraud Risk\nEvery banking transaction—payments, transfers, withdrawals—passes through initiation, authorization, clearing, and settlement. Fraud risk is present at each stage, requiring layered controls. Real-time monitoring and post-settlement reconciliation are critical to detect anomalies early and minimize losses.",
                isViewed: false
            ),
            LearnCard(
                title: "Key Fraud Types in Banking",
                content: "Common frauds include card skimming, account takeover, APP (authorized push payment) scams, and money laundering. Each type exploits different vulnerabilities in the transaction flow. Understanding these patterns helps tailor detection rules and response protocols to specific threats faced by your institution.",
                isViewed: false
            ),
            LearnCard(
                title: "Fraud Detection Architecture",
                content: "Modern systems combine rule-based engines, machine learning models, and real-time analytics. Data from multiple channels is aggregated to build customer risk profiles. This architecture enables both instant blocking of high-risk transactions and deeper investigation of suspicious patterns, balancing speed and accuracy.",
                isViewed: false
            ),
            LearnCard(
                title: "Real-Time Monitoring Essentials",
                content: "Real-time systems evaluate transaction amount, location, device, and behavioral history to flag anomalies. For example, a large transfer from a new device triggers enhanced scrutiny. Low-latency processing ensures timely intervention, reducing the window for fraudsters to exploit gaps.",
                isViewed: false
            ),
            LearnCard(
                title: "AI & Machine Learning in Detection",
                content: "AI models learn from historical fraud patterns to identify subtle, evolving schemes. Ensemble techniques (e.g., logistic regression with K-NN) improve detection rates while reducing false positives. Continuous model retraining adapts to new fraud tactics, maintaining robust defense.",
                isViewed: false
            ),
            LearnCard(
                title: "Metrics That Matter: Precision & Recall",
                content: "Effective fraud systems balance precision (minimizing false alarms) and recall (catching true fraud). The F1-score harmonizes these metrics, while ROC AUC measures overall discriminative power. Regular validation ensures models perform under changing transaction volumes and fraud trends.",
                isViewed: false
            ),
            LearnCard(
                title: "Collaborative Fraud Prevention",
                content: "Platforms like Salv Bridge enable banks to share anonymized fraud scenarios and alerts across institutions. This collective intelligence speeds up detection, recovery, and adaptation to emerging threats. Encryption ensures data privacy while maximizing collaborative gains.",
                isViewed: false
            ),
            LearnCard(
                title: "Integrating Fraud Solutions",
                content: "Leading solutions (e.g., Feedzai, HAWK:AI) integrate with core banking systems, ingesting transaction data and enriching decisioning with external intelligence. Flexible APIs and explainable AI empower analysts to refine rules and investigate cases efficiently, without disrupting operations.",
                isViewed: false
            ),
            LearnCard(
                title: "Regulatory & Operational Challenges",
                content: "Banks must comply with evolving AML/CFT regulations while minimizing customer friction. Overly aggressive fraud controls can increase false positives and harm customer experience. Striking the right balance requires clear policies, staff training, and regular audits.",
                isViewed: false
            ),
            LearnCard(
                title: "Further Learning & Documentation",
                content: "Deepen your expertise with official resources: review FFIEC guidance on fraud risk management, explore NIST frameworks for AI in financial services, and consult your core banking vendor’s fraud module documentation. Engage with industry forums and regulatory updates to stay ahead of threats.",
                isViewed: false
            )
        ]

        static let creditCardOperationsCards: [LearnCard] = [
            LearnCard(
                title: "Topic: Credit Card Operations",
                content: "Credit Card Operations Overview\nCredit card operations encompass the end-to-end processes for issuing, authorizing, clearing, and settling transactions. For banking professionals, understanding these flows is essential for managing risk, compliance, and customer experience. This overview sets the stage for deeper exploration of transaction mechanics and operational controls.",
                isViewed: false
            ),
            LearnCard(
                title: "Key Stakeholders & Roles",
                content: "Credit card operations involve issuers, acquirers, card networks, merchants, and cardholders. Each party has distinct responsibilities: issuers manage credit risk and customer accounts, acquirers facilitate merchant onboarding and transaction processing, while networks ensure interoperability and settlement. Coordination is crucial for seamless transaction flow.",
                isViewed: false
            ),
            LearnCard(
                title: "Transaction Authorization Process",
                content: "Authorization validates the cardholder’s credit and checks for fraud in real time. The merchant’s request is routed via the acquirer and card network to the issuer, who approves or declines based on account status and risk parameters. Quick, accurate authorization is vital for customer satisfaction and loss prevention.",
                isViewed: false
            ),
            LearnCard(
                title: "Clearing & Settlement Dynamics",
                content: "Clearing transmits batched transaction data from merchants to issuers, converting holds into actual charges. Settlement follows, moving funds through the network to the merchant’s account, minus fees. Timely and accurate clearing and settlement are essential for liquidity management and reconciliation.",
                isViewed: false
            ),
            LearnCard(
                title: "Reconciliation & Exception Handling",
                content: "Reconciliation matches transaction records across banks, networks, and merchants to ensure accuracy. Exceptions, such as mismatches or duplicate entries, require prompt investigation and resolution. Effective reconciliation minimizes financial discrepancies and supports regulatory compliance.",
                isViewed: false
            ),
            LearnCard(
                title: "Risk Controls & Fraud Management",
                content: "Banks deploy real-time monitoring, rule-based controls, and machine learning to detect suspicious activity during authorization and post-settlement. Scenario-driven reviews, such as sudden spending spikes or cross-border anomalies, trigger alerts and potential transaction holds. Proactive fraud management protects both the bank and its customers.",
                isViewed: false
            ),
            LearnCard(
                title: "Regulatory Compliance Essentials",
                content: "Credit card operations must comply with PCI DSS, AML, and consumer protection regulations. Banks regularly audit transaction flows, maintain robust data security protocols, and report suspicious activities. Compliance failures can result in penalties and reputational damage, making ongoing training and process review critical.",
                isViewed: false
            ),
            LearnCard(
                title: "Operational Efficiency & Technology",
                content: "Automation in transaction processing, exception handling, and reporting drives operational efficiency. Scenario: Implementing AI-driven reconciliation reduces manual workload and error rates. Banks investing in modern platforms and APIs can adapt quickly to evolving payment trends and customer expectations.",
                isViewed: false
            ),
            LearnCard(
                title: "Emerging Trends & Innovations",
                content: "Real-time payments, tokenization, and digital wallets are reshaping credit card operations. Banks must adapt their systems to support new transaction types and security models. Scenario: Integrating tokenized payments reduces fraud risk and streamlines customer experience, but requires updates to legacy infrastructure.",
                isViewed: false
            ),
            LearnCard(
                title: "Further Learning & Documentation",
                content: "Next steps: Deepen expertise in PCI DSS, AML, and digital payment innovations. Explore related concepts: chargebacks, dispute resolution, and merchant onboarding. Official resources:\n\nPCI Security Standards Council\nFederal Reserve Payments Systems\nFDIC Credit Card Banking",
                isViewed: false
            )
        ]

        static let loanProcessingCards: [LearnCard] = [
            LearnCard(
                title: "Topic: Loan Processing and Credit Risk Assessment",
                content: "Loan Processing Overview\nLoan processing is a multi-stage workflow that transforms a borrower’s application into a funded loan. Each stage—application, verification, underwriting, approval, and servicing—requires careful coordination between teams to minimize risk and ensure regulatory compliance. Understanding this end-to-end process is essential for effective risk management.",
                isViewed: false
            ),
            LearnCard(
                title: "Application & Initial Screening",
                content: "Loan officers collect detailed borrower information, including financial statements and credit history. Early screening flags incomplete or inconsistent data, enabling quick rejection of high-risk applications and reducing wasted resources. Effective pre-screening sets the tone for downstream risk controls.",
                isViewed: false
            ),
            LearnCard(
                title: "Document Verification Challenges",
                content: "Verification teams must authenticate income statements, tax returns, and asset records. Discrepancies or fraudulent documents can derail the process, so robust verification protocols and digital tools are essential. Scenario: A flagged tax return prompts additional checks, delaying approval but averting potential loss.",
                isViewed: false
            ),
            LearnCard(
                title: "Credit Evaluation Techniques",
                content: "Credit analysts assess credit scores, payment history, and debt levels to gauge borrower risk. Advanced scoring models and trend analysis help identify applicants with hidden risk factors. For example, a borrower with a strong score but rising debt may warrant closer scrutiny.",
                isViewed: false
            ),
            LearnCard(
                title: "Loan Underwriting Decisions",
                content: "Underwriters synthesize financial data, collateral value, and borrower capacity to repay. Automated underwriting systems expedite routine cases, while complex loans require manual review. A scenario: An underwriter questions collateral valuation, triggering a re-appraisal before final approval.",
                isViewed: false
            ),
            LearnCard(
                title: "Approval & Disbursement Protocols",
                content: "Approved loans move to final documentation and fund disbursement. Approval committees review risk grades and policy exceptions. Funds are released only after compliance checks and borrower acceptance of terms, ensuring regulatory and operational safeguards are met.",
                isViewed: false
            ),
            LearnCard(
                title: "Ongoing Loan Servicing",
                content: "Servicing teams monitor repayments, covenant compliance, and borrower communications. Early detection of missed payments or covenant breaches triggers intervention protocols. Scenario: A borrower misses two payments, prompting escalation to the collections team and review of restructuring options.",
                isViewed: false
            ),
            LearnCard(
                title: "Credit Risk Assessment Tools",
                content: "Banks deploy risk matrices, financial covenants, and collateral tables to quantify and monitor credit risk. Objective metrics—such as debt service coverage and liquidity ratios—are supplemented by subjective factors like management quality. Regular reviews ensure risk ratings remain current and actionable.",
                isViewed: false
            ),
            LearnCard(
                title: "Mitigating Credit Risk",
                content: "Risk mitigation strategies include requiring additional collateral, imposing stricter covenants, and using insurance products. Scenario: For a borrower with marginal cash flow, the bank may require a personal guarantee or adjust the loan structure to reduce exposure.",
                isViewed: false
            ),
            LearnCard(
                title: "Further Learning & Documentation",
                content: "Next steps: Explore advanced underwriting, portfolio risk modeling, and regulatory compliance. Related concepts: loan origination, stress testing, Basel III. Official resources: OCC Lending Standards, FDIC Credit Risk Management, Basel Committee on Banking Supervision.",
                isViewed: false
            )
        ]

        static let customerOnboardingCards: [LearnCard] = [
            LearnCard(
                title: "Topic: Customer Onboarding and Account Management",
                content: "Onboarding & Account Management Overview\nCustomer onboarding in banking is a multi-stage process that sets the tone for the entire client relationship. It encompasses regulatory compliance, risk assessment, and customer experience. Effective onboarding drives retention, ensures compliance, and lays the foundation for personalized account management.",
                isViewed: false
            ),
            LearnCard(
                title: "Key Stages of Onboarding",
                content: "The onboarding journey typically includes pre-application, application, identity verification, account opening, product enrollment, funding, and finalization. Each stage requires seamless coordination to minimize friction and ensure regulatory adherence, while also capturing essential customer data for future engagement.",
                isViewed: false
            ),
            LearnCard(
                title: "KYC, AML, and Compliance Essentials",
                content: "Know Your Customer (KYC) and Anti-Money Laundering (AML) checks are non-negotiable. Banks must collect and validate IDs, proof of address, and screen for politically exposed persons. Automated systems and digital verification tools can accelerate compliance while reducing manual errors and onboarding delays.",
                isViewed: false
            ),
            LearnCard(
                title: "Digital Identity Verification in Practice",
                content: "Modern onboarding leverages biometric authentication, video KYC, and OCR-enabled document capture. For example, a customer can complete identity verification remotely using facial recognition and digital signatures, reducing branch visits and expediting account activation.",
                isViewed: false
            ),
            LearnCard(
                title: "Risk Profiling and Customer Segmentation",
                content: "Banks assess new customers’ risk profiles using background checks, transaction history, and behavioral analytics. This enables segmentation for tailored product offerings and proactive monitoring, helping to mitigate fraud and ensure appropriate account controls are in place.",
                isViewed: false
            ),
            LearnCard(
                title: "Personalization and Product Recommendations",
                content: "Effective onboarding captures customer preferences and financial goals, enabling banks to recommend relevant products—such as savings, credit, or investment options. Scenario: A young professional is offered a bundled account with digital tools and investment starter kits based on their profile.",
                isViewed: false
            ),
            LearnCard(
                title: "Automation and Workflow Integration",
                content: "Automated onboarding workflows integrate with CRM and core banking systems, reducing manual data entry and turnaround times. For instance, APIs can pull data from trusted sources, auto-populate forms, and trigger real-time risk checks, enhancing both efficiency and customer satisfaction.",
                isViewed: false
            ),
            LearnCard(
                title: "Ongoing Account Management Practices",
                content: "Account management is continuous, involving periodic KYC refreshes, transaction monitoring, and proactive engagement. Banks use analytics to detect unusual activity and offer timely support, ensuring compliance and deepening customer relationships over the account lifecycle.",
                isViewed: false
            ),
            LearnCard(
                title: "Measuring Success: Metrics & Feedback",
                content: "Key performance indicators include onboarding completion time, drop-off rates, customer satisfaction, and compliance breaches. Dashboards and post-onboarding surveys help identify bottlenecks and inform process improvements, ensuring the onboarding experience evolves with customer and regulatory demands.",
                isViewed: false
            ),
            LearnCard(
                title: "Further Learning & Documentation",
                content: "Next steps: Deepen expertise in digital onboarding, advanced KYC, and customer lifecycle management. Explore related concepts: customer journey mapping, regulatory technology, and data privacy. Official resources: FATF Guidance, FinCEN, EBA Guidelines.",
                isViewed: false
            )
        ]

        static let paymentServicesCards: [LearnCard] = [
            LearnCard(
                title: "Topic: Payment Services Overview",
                content: "Payment services encompass the systems and processes that move money between parties, including card networks, ACH, wire transfers, instant payments, and digital wallets. Banks, processors, and fintechs collaborate to ensure secure, reliable, and compliant funds movement across domestic and cross-border rails.",
                isViewed: false
            ),
            LearnCard(
                title: "Payment Rails & Instruments",
                content: "Common rails include card networks (Visa/Mastercard), ACH for batch low-cost transfers, RTGS/wires for high-value real-time settlement, and instant payment schemes (e.g., RTP, FedNow). Instruments span cards, bank accounts, tokenized credentials, and wallets—each with distinct settlement, cost, and risk profiles.",
                isViewed: false
            ),
            LearnCard(
                title: "Authorization, Clearing, Settlement",
                content: "Authorization confirms funds and risk in real time. Clearing exchanges financial messages and final transaction details. Settlement moves funds between institutions, net or gross, depending on the rail. Understanding these stages helps optimize liquidity, reduce disputes, and improve customer experience.",
                isViewed: false
            ),
            LearnCard(
                title: "Risk, Compliance, and Fraud Controls",
                content: "Payment services must comply with AML/CFT, sanctions (OFAC), and data security (PCI DSS). Controls include KYC, transaction monitoring, velocity checks, device fingerprinting, and SCA/2FA. Effective fraud strategy balances precision and recall to minimize losses and customer friction.",
                isViewed: false
            ),
            LearnCard(
                title: "Operational Considerations",
                content: "Key operations include exception handling, reconciliations, chargebacks/disputes, returns (e.g., ACH R-codes), and cut-off management. Robust SLAs, monitoring, and incident playbooks ensure uptime. Automation and straight-through processing reduce costs and error rates across the payment lifecycle.",
                isViewed: false
            ),
            LearnCard(
                title: "Trends: Real-Time & Embedded Payments",
                content: "Real-time rails and open APIs enable embedded payments within apps and platforms. Tokenization, network tokens, and push-to-card payouts improve security and speed. ISO 20022 enhances data richness for compliance and analytics, while cross-border innovations aim to reduce cost and settlement time.",
                isViewed: false
            )
        ]
}
