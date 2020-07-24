describe('my beverage', () => {
  test('is delicious', () => {
      expect({"hi": "there"}).toMatchSnapshot();
  });

  test('Dummy test test', () => {
      expect({"name": "Danie"}).toMatchSnapshot();
  });
});
