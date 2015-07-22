CREATE TABLE "commit" (
    "sha" TEXT NOT NULL,
    "revisions" INTEGER NOT NULL,
    "author" TEXT NOT NULL,
    "date" TEXT NOT NULL,
    "comment" TEXT
);
CREATE TABLE "ticket_commit_assoc" (
    "ticket" TEXT NOT NULL,
    "sha" TEXT NOT NULL
);
CREATE TABLE "commit_file" (
    "sha" TEXT NOT NULL,
    "filename" TEXT NOT NULL,
    "operation" TEXT NOT NULL
);
CREATE TABLE "merge" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "from" TEXT NOT NULL
);
CREATE TABLE sqlite_sequence(name,seq);
CREATE TABLE "merge_commit_assoc" (
    "merge_id" INTEGER NOT NULL,
    "sha" TEXT NOT NULL
);
