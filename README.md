# Rails Training API

Rails 7 API モードアプリケーション（Docker + PostgreSQL + Redis構成）

## 技術スタック

- **Ruby**: 3.2.9
- **Rails**: 7.2.2 (API モード)
- **Database**: PostgreSQL 15
- **Cache**: Redis 7
- **Testing**: RSpec
- **Container**: Docker & Docker Compose

## 要件

- Docker
- Docker Compose

## セットアップ

### 1. リポジトリをクローン

```bash
git clone <repository-url>
cd rails-training
```

### 2. Docker環境でアプリケーションを起動

```bash
# バックグラウンドで起動
docker-compose up -d

# フォアグラウンドで起動（ログ表示）
docker-compose up
```

### 3. 動作確認

アプリケーションが正常に起動したら、以下のエンドポイントでヘルスチェックできます：

```bash
# Rails標準ヘルスチェック
curl http://localhost:3000/up

# カスタムヘルスチェック（データベース・Redis接続状況）
curl http://localhost:3000/health
```

### 4. 停止

```bash
docker-compose down
```

## 開発

### コンテナ内でRailsコマンドを実行

```bash
# Railsコンソール
docker-compose exec web rails console

# テスト実行
docker-compose exec web rspec

# マイグレーション
docker-compose exec web rails db:migrate
```

### 新しいgemを追加

1. `Gemfile`を編集
2. イメージを再ビルド: `docker-compose build`
3. アプリケーションを再起動: `docker-compose up`

## API仕様

### エンドポイント一覧

| Method | Path | Description |
|--------|------|-------------|
| GET | `/up` | Rails標準ヘルスチェック |
| GET | `/health` | カスタムヘルスチェック（JSON） |

### ヘルスチェックレスポンス例

```json
{
  "status": "ok",
  "timestamp": "2025-08-25T07:00:00Z",
  "version": "1.0.0",
  "services": {
    "database": "connected",
    "redis": "connected"
  }
}
```

## アーキテクチャ

### コンテナ構成

- **web**: Rails APIサーバー (ポート3000)
- **db**: PostgreSQL データベース (ポート5432)
- **redis**: Redis キャッシュサーバー (ポート6379)

### ディレクトリ構造

```
├── app/
│   ├── controllers/        # APIコントローラー
│   ├── models/            # データモデル
│   └── jobs/              # バックグラウンドジョブ
├── config/                # Rails設定
├── spec/                  # RSpecテスト
├── docker-compose.yml     # Docker構成
├── Dockerfile            # Rails用Dockerイメージ
└── entrypoint.sh         # コンテナ起動スクリプト
```

## トラブルシューティング

### コンテナが起動しない場合

```bash
# ログを確認
docker-compose logs web

# 強制再ビルド
docker-compose build --no-cache

# 全てのコンテナとネットワークを削除してやり直し
docker-compose down -v
docker-compose up
```

### データベース接続エラー

```bash
# データベースコンテナの状態確認
docker-compose logs db

# データベースを再初期化
docker-compose down -v
docker-compose up
```

## License

This project is licensed under the MIT License.
