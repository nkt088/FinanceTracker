FinanceTracker
Домашняя работа 1
Я реализовал бизнес логику, а также задания * и **
Если во время проверки возникли вопросы: tg: @nktmahov

Ниже будет описание файлов проекта для более удобной и быстрой проверки:
Dir: Models 
Структуры (struct): — используются не все, только основные 3 и enum
- Category
- Transaction
- TransactionRequest
- TransactionResponse
- Account
- AccountBrief
- AccountState
- AccountHistory
- AccountHistoryResponse
- AccountCreateRequest
- AccountUpdateRequest
- StatItem
Перечисления (enum):
- Direction
- AccountChangeType

Dir: Services
- CategoriesService
- TransactionsService
- BankAccountsService

Dir: Storage
- TransactionsFileCache

Dir: Extensions — это одно расширение, логика разделена на два файла
- Transaction — JSON методы
- Transaction+CSV —CSV методы

Dir: MockData
- CategoriesMock
- TransactionsMock
- BankAccountsMock

Dir: FinanceTrackerTests — 4 теста JSON и CSV
- FinanceTrackerTests
