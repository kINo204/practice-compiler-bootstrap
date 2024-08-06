int main() {
    int a = 0;
    {
        int b = 1;
        {
            int a = 4;
            {
                a = 5;
            }
        }
    }
    return b;
}
